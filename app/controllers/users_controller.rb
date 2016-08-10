# frozen_string_literal: true

# Allows user management by system admins
class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_system_admin, only: [:new, :create, :edit, :update, :destroy]
  before_action :find_user_or_redirect, only: [:show, :edit, :update, :destroy]

  def index
    unless current_user.system_admin? or params[:format] == 'json'
      redirect_to root_path, alert: "You do not have sufficient privileges to access that page."
      return
    end

    @order = scrub_order(User, params[:order], 'users.current_sign_in_at desc')
    @users = User.current.search(params[:search] || params[:q]).order(@order).page(params[:page]).per( 40 )

    respond_to do |format|
      format.html
      format.json do # TODO: Put into jbuilder instead!
        render json: params[:q].to_s.split(',').collect{ |u| (u.strip.downcase == 'me') ? { name: current_user.name, id: current_user.name } : { name: u.strip.titleize, id: u.strip.titleize } } + @users.collect{ |u| { name: u.name, id: u.name } }
      end
    end
  end

  # GET /users/1
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users/activate
  def activate
    params[:user] ||= {}
    params[:user][:password] = params[:user][:password_confirmation] = Digest::SHA1.hexdigest(Time.zone.now.usec.to_s)[0..19] if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
    @user = User.new(user_params)
    if @user.save
      UserMailer.status_activated(@user).deliver_now if EMAILS_ENABLED && @user.status == 'active'
      redirect_to @user, notice: 'User was successfully created.'
    else
      render :new
    end
  end

  # PATCH /users/1
  def update
    original_status = @user.status
    if @user.update(user_params)
      UserMailer.status_activated(@user).deliver_now if EMAILS_ENABLED && original_status != @user.status && @user.status == 'active'
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
    redirect_to users_path, notice: 'User was successfully deleted.'
  end

  private

  def find_user_or_redirect
    @user = User.current.find_by_id params[:id]
    redirect_without_user
  end

  def redirect_without_user
    empty_response_or_root_path(users_path) unless @user
  end

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :email, :password, :password_confirmation,
      :pp_committee, :pp_committee_secretary, :steering_committee,
      :steering_committee_secretary, :system_admin, :status
    )
  end
end
