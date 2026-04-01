class PasswordsController < ApplicationController
  NOT_IMPLEMENTED_MESSAGE = "Password reset is not available for this application.".freeze

  def new
    render plain: NOT_IMPLEMENTED_MESSAGE, status: :not_implemented
  end

  def edit
    render plain: NOT_IMPLEMENTED_MESSAGE, status: :not_implemented
  end
end
