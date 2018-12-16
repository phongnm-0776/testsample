class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]
  def new; end

  def create
    @user = User.find_by email: params[:password_reset][:email].downcase
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t "flash.email_reset"
      redirect_to root_url
    else
      flash.now[:danger] = t "flash.wrong_email"
      render :new
    end
  end

  def edit; end

  def update
    if params[:user][:password].empty? # Case (3)
      @user.errors.add(:password, :blank)
      render :edit
    elsif @user.update_attributes(user_params) # Case (4)
      log_in @user
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = t "flash.success_reset"
      redirect_to @user
    else
      render :edit # Case (2)
    end
  end

  private
  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def get_user
    return if @user = User.find_by(email: params[:email])
    redirect_to root_path
    flash[:danger] = t "flash.nouser"
  end

  # Confirms a valid user.
  def valid_user
    redirect_to root_url unless @user && @user.activated? &&
                                @user.authenticated?(:reset, params[:id])
  end

  # Checks expiration of reset token.
  def check_expiration
    return unless @user.password_reset_expired?
    flash[:danger] = t "flash.expire_reset"
    redirect_to new_password_reset_url
  end
end
