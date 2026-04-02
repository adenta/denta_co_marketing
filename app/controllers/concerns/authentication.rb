module Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
    end

    def require_authenticated_access(**options)
      before_action :require_authentication, **options
    end

    def disallow_authenticated_access(**options)
      before_action :redirect_if_authenticated, **options
    end

    def disallow_authenticated_api_access(**options)
      before_action :render_already_authenticated, **options
    end
  end

  private
    def authenticated?
      resume_session.present?
    end

    def require_authentication
      resume_session || request_authentication
    end

    def require_blazer_access
      resume_session || request_blazer_authentication
    end

    def resume_session
      Current.session ||= find_session_by_cookie
    end

    def find_session_by_cookie
      Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
    end

    def request_authentication
      if request.format.json?
        render json: {
          message: "You need to sign in before continuing.",
          redirect_to: new_session_path
        }, status: :unauthorized
      else
        session[:return_to_after_authenticating] = request.url
        redirect_to new_session_path
      end
    end

    def request_blazer_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to main_app.new_session_path
    end

    def redirect_if_authenticated
      redirect_to after_authentication_url, notice: already_authenticated_message if resume_session
    end

    def render_already_authenticated
      return unless resume_session

      render json: {
        message: already_authenticated_message,
        redirect_to: after_authentication_url
      }, status: :conflict
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || root_url
    end

    def already_authenticated_message
      "You are already signed in."
    end

    def start_new_session_for(user)
      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        Current.session = session
        cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
        ahoy.authenticate(user)
        ahoy.track "Signed in"
      end
    end

    def terminate_session
      Current.session.destroy
      cookies.delete(:session_id)
    end
end
