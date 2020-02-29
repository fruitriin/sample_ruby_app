class SessionsController < ApplicationController
  include SessionsHelper

  def new
  end

  def create
    user = User.find_by_email(params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
    #  ユーザーログイン後にユーザー情報ページにリダイレクト
      log_in user
      params[:session][:remember_me] == "1" ? remember(user) : forget(user)
      redirect_to user
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    forget(current_user)
    session[:user_id] = nil
    redirect_to root_url
  end

  def log_in(user)
    session[:user_id] = user.id
  end
end
