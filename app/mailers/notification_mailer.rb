class NotificationMailer < ActionMailer::Base

  default from: "#{APPLICATION_NAME} <#{APPLICATION_EMAIL_ADDRESS}>"
  #layout 'mailer'

  def password_reset_email(user)
    @user = user
    @url = "#{Rails.configuration.action_mailer.default_url_options[:host]}/password/reset/#{@user.reset_password_token}"
    @hours_to_reset_password = User.hours_to_reset_password

    to = @user.email_address_with_name
    cc = nil
    mail(to: to, cc: cc, subject: "Link to reset your password for the #{APPLICATION_NAME} website")

  end

  def new_user_email(new_user,added_by)
    @new_user = new_user
    @added_by  = added_by
    @main_app_url = "#{Rails.configuration.action_mailer.default_url_options[:host]}"
    @password_reset_url = "#{Rails.configuration.action_mailer.default_url_options[:host]}/password/reset/#{@new_user.reset_password_token}"
    @hours_to_log_in = User.hours_to_do_first_login

    cc = @added_by.email_address_with_name
    to = @new_user.email_address_with_name
    bcc = APPLICATION_EMAIL_ADDRESS

    mail(to: to, cc: cc, bcc: bcc, subject: "A login for the #{APPLICATION_NAME} website has been created for you")

  end

end
