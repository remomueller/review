class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_system_admin, :only => [:new, :create, :edit, :update, :destroy]

  def index
    unless current_user.system_admin? or params[:format] == 'json'
      redirect_to root_path, alert: "You do not have sufficient privileges to access that page."
      return
    end
    current_user.update_attribute :users_per_page, params[:users_per_page].to_i if params[:users_per_page].to_i >= 10 and params[:users_per_page].to_i <= 200
    @order = params[:order].blank? ? 'users.current_sign_in_at DESC' : params[:order]
    users_scope = User.current
    @search_terms = (params[:search] || params[:q]).to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| users_scope = users_scope.search(search_term) }
    users_scope = users_scope.order(@order)
    @users = users_scope.page(params[:page]).per(current_user.users_per_page)
    respond_to do |format|
      format.html
      format.js
      format.json { render :json => params[:q].to_s.split(',').collect{|u| (u.strip.downcase == 'me') ? {:name => current_user.name, id: current_user.name} : {:name => u.strip.titleize, id: u.strip.titleize}} + @users.collect{|u| {:name => u.name, id: u.name}}}
    end
  end

  def show
    @user = User.find_by_id(params[:id])
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find_by_id(params[:id])
  end

  # # This is in registrations_controller.rb
  # def create
  # end

  # Post /users/activate.json
  def activate
    params[:user] ||= {}
    params[:user][:password] = params[:user][:password_confirmation] = Digest::SHA1.hexdigest(Time.now.usec.to_s)[0..19] if params[:user][:password].blank? and params[:user][:password_confirmation].blank?
    @user = User.new(params[:user])
    if @user.save
      [:pp_committee, :pp_committee_secretary, :steering_committee, :steering_committee_secretary, :system_admin, :status].each do |attribute|
        @user.update_attribute attribute, params[:user][attribute]
      end

      respond_to do |format|
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render json: @user, only: [:id, :first_name, :last_name, :email, :status], status: :created, location: @user }
      end
    else
      respond_to do |format|
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @user = User.find_by_id(params[:id])
    if @user.update_attributes(params[:user])
      [:pp_committee, :pp_committee_secretary, :steering_committee, :steering_committee_secretary, :system_admin, :status].each do |attribute|
        @user.update_attribute attribute, params[:user][attribute]
      end
      redirect_to(@user, notice: 'User was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @user = User.find_by_id(params[:id])
    @user.destroy
    redirect_to users_path
  end
end
