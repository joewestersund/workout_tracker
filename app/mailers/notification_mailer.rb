class NotificationMailer < ActionMailer::Base

  default from: "#{APPLICATION_NAME} <#{APPLICATION_EMAIL_ADDRESS}>"

  def password_reset_email(user)
    @user = user
    @url = "#{Rails.configuration.action_mailer.default_url_options[:host]}/password/reset/#{@user.reset_password_token}"
    @hours_to_reset_password = User.hours_to_reset_password

    to = @user.email_address_with_name
    cc = nil
    mail(to: to, cc: cc, subject: "Link to reset your password for the #{APPLICATION_NAME} website")

  end

  def new_user_email(new_user)
    @user = new_user
    @main_app_url = "#{Rails.configuration.action_mailer.default_url_options[:host]}"
    @account_activation_url = "#{Rails.configuration.action_mailer.default_url_options[:host]}/activate_account/#{@user.reset_password_token}"
    @login_url = "#{Rails.configuration.action_mailer.default_url_options[:host]}/signin"
    @hours_to_log_in = User.hours_to_do_first_login

    to = @user.email_address_with_name

    mail(to: to, subject: "Activate your #{APPLICATION_NAME} account")

  end

end
