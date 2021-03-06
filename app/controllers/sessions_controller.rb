class SessionsController < ApplicationController
  def new

  end

  def create
    user = User.find_by(email: params[:email].downcase)
    if user && user.authenticate(params[:password])
      sign_in user
      redirect_to workouts_path
    else
      flash.now[:error] = "Invalid username / password"
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end
end
