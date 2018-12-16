class SessionsController < ApplicationController
  def new; end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    login_user params
  end

  def destroy
    log_out if logged_in?
    redirect_to root_path
  end
end
