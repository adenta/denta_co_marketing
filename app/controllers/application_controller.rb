class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  helper_method :current_user
  skip_before_action :track_ahoy_visit, if: :json_request?

  rescue_from Pundit::NotAuthorizedError, with: :handle_not_authorized

  private

  def current_user
    Current.user
  end

  def pundit_user
    current_user
  end

  def default_render
    super
  rescue ActionController::MissingExactTemplate, ActionView::MissingTemplate
    # Interactive pages are expected to live in app/javascript/pages/<controller>/<action>.tsx
    # and receive serializable data via @props, rather than adding per-action ERB templates.
    raise unless fallback_page_renderable?

    render(
      template: "shared/page_fallback",
      locals: {
        component_name: fallback_component_name,
        props: @props || {}
      },
    )
  end

  def fallback_page_renderable?
    request.get? && request.format.html? && !request.xhr? && fallback_component_file.exist?
  end

  def fallback_component_name
    # Keep this naming contract in sync with app/javascript/turbo-mount.js.
    "#{controller_path}/#{action_name}"
  end

  def fallback_component_file
    Rails.root.join("app/javascript/pages/#{fallback_component_name}.tsx")
  end

  def handle_not_authorized
    respond_to do |format|
      format.json do
        render(
          json: {
            message: "You are not authorized to perform that action.",
            redirect_to: root_path
          },
          status: :forbidden,
        )
      end

      format.any do
        redirect_to root_path, alert: "You are not authorized to perform that action."
      end
    end
  end

  def json_request?
    request.format.json?
  end
end
