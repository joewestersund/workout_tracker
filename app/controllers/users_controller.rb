class UsersController < ApplicationController
  include UsersHelper
  include ActionView::Helpers::TextHelper  # for pluralize method

  before_action :signed_in_user, only: [:edit_profile, :update, :destroy ]
  before_action :signed_in_user_unactivated_ok, only: [ :edit_password, :update_password ]
  before_action :set_self_as_user, only: %i[ edit_profile update update_profile edit_password update_password destroy ]


  # GET /users/new
  def new
    @user = User.new
  end

  def create
    if (verify_recaptcha(model: @user) || Rails.env == "development")
      @user = User.new(user_params_new)

      #create a temporary password. We won't tell them what it is, but it will prevent anyone from logging into this account until they create one
      pw = User.generate_random_password
      @user.password = pw
      @user.password_confirmation = pw

      if @user.save

        sign_in @user

        @user.generate_password_token!
        NotificationMailer.new_user_email(@user).deliver

        notice_text = "We've sent an email to you at #{@user.email}. Please use the link in that email to set your password and activate your account."

        redirect_to activate_path, notice: notice_text
      else
        render 'new'
      end
    else
      render 'new'
    end
  end

  def edit_profile
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
        if !@user.activated?
          # this user just created their password for the first time
          notice_text = "Welcome to Log My Workout!"
          create_user_defaults(@user)
          flash[:notice] =
          @user.activated = true
          @user.save
        else
          notice_text = 'Your password was successfully updated.'
        end

        format.html { redirect_to workouts_path, notice: notice_text }
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
    if @user.present? && (verify_recaptcha(model: @user) || Rails.env == "development")
      @user.generate_password_token!
      NotificationMailer.password_reset_email(@user).deliver
      redirect_to signin_path, notice: "A password reset email has been sent to #{@user.name} at #{@user.email}. Please use the link in that email to reset your password in the next #{pluralize(User.hours_to_reset_password,"hour")}."
    else
      redirect_to password_forgot_path, alert: "That email address was not recognized, or the recaptcha was not recognized."
    end
  end

  def resend_activation_email
    @user = User.find_by(email: params[:email])
    if @user.present? && (verify_recaptcha(model: @user) || Rails.env == "development")

      @user.generate_password_token!
      NotificationMailer.new_user_email(@user).deliver

      notice_text = "We've sent an email to you at #{@user.email}. Please use the link in that email to set your password and activate your account."

      redirect_to activate_path, notice: notice_text
    end
  end

  def reset_password
    @user = User.find_by(reset_password_token: params[:token]) if !params[:token].blank?
    if @user.present? && @user.password_token_valid? then
      sign_in @user

      #erase the password reset token, so they can't reset it again with that same link
      @user.reset_password_token = nil
      @user.save

      if @user.activated?
        notice_text = "Please enter a new password"
      else
        # this user will just be creating their password for the first time
        notice_text = "Please enter a password"
      end

      flash[:notice] = notice_text
      render :edit_password
    else
      flash[:alert] = "That email address was not recognized, or its password reset link has expired."
      redirect_to password_forgot_path
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_self_as_user
      @user = self.current_user
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

end
