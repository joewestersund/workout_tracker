class UsersController < ApplicationController
  before_action :signed_in_user, only: [:edit, :edit_password, :update, :update_password, :show, :destroy, :index]
  before_action :set_user, only: %i[ show edit update destroy ]

  # GET /users or /users.json
  def index
    @users = User.all
  end

  # GET /users/1 or /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params_new)
    if @user.save
      sign_in @user
      create_user_defaults(@user)
      flash[:notice] = "Welcome to the Spending Tracker! We've set up some default account names and transaction categories for you."
      redirect_to welcome_path
    else
      render 'new'
    end
  end

  # GET /users/1/edit
  def edit
  end

  def edit_password
  end

  def update
    params[:user].delete(:password) #don't update the password here.
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to profile_edit_path, notice: 'Your profile was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_password
    respond_to do |format|
      if params[:user][:password].present? and @user.update(user_params_change_password)
        format.html { redirect_to comments_path, notice: 'Your password was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit_password' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def forgot_password
  end

  def send_password_reset_email
    @user = User.find_by(email: params[:email])
    respond_to do |format|
      if @user.present? && @user.active? && (verify_recaptcha(model: @user) || Rails.env == "development")
        @user.generate_password_token!
        NotificationMailer.password_reset_email(@user).deliver
        format.html { redirect_to signin_path, notice: "A password reset email has been sent to #{@user.name} at #{@user.email}. Please use the link in that email to reset your password in the next #{pluralize(User.hours_to_reset_password,"hour")}." }
      else
        format.html { redirect_to password_forgot_path, alert: "That email address was not recognized, or the recaptcha was not recognized." }
      end
    end
  end

  def reset_password
    respond_to do |format|
      user = User.find_by(reset_password_token: params[:token]) if !params[:token].blank?
      if user.present? && user.password_token_valid? then
        sign_in user

        #erase the password reset token, so they can't reset it again with that same link
        user.reset_password_token = nil
        user.save

        format.html {redirect_to profile_edit_password_path, notice: "Please enter a new password"}
      else
        format.html {redirect_to password_forgot_path, alert: "That email address was not recognized, or its password reset link has expired."}
      end
    end
  end

  def destroy
    sign_out
    @user.destroy
    respond_to do |format|
      format.html { redirect_to signup_path }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:name, :email, :time_zone)
    end

    def user_params_new
      params.require(:user).permit(:name, :email, :time_zone, :password, :password_confirmation)
    end

    def user_params_change_password()
      params.require(:user).permit(:password, :password_confirmation)
    end

    def create_user_defaults(user)
      # what needs to be inserted?
    end

end
