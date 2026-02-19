class UsersController < ApplicationController
  skip_before_action :require_authentication, only: [ :new, :create ]

  def new
    if signed_in?
      redirect_to root_path, notice: "You are already signed in."
      return
    end

    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      start_session!(@user)
      redirect_to root_path, notice: "Your account has been created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.expect(user: [ :name, :email, :password, :password_confirmation ])
  end
end
