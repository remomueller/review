class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_system_admin, :only => [:new, :create, :edit, :update, :destroy]

  # Retrieves filtered list of users.
  def filtered
    @search = params[:search]
    @relation = params[:relation]
    render :partial => 'user_select_filter'
  end
  
  def index
    @users = User.current
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

  def update
    @user = User.find_by_id(params[:id])
    if @user.update_attributes(params[:user])      
      [:pp_committee, :pp_committee_secretary, :steering_committee, :steering_committee_secretary, :system_admin, :status].each do |attribute|
        @user.update_attribute attribute, params[:user][attribute]
      end
      redirect_to(@user, :notice => 'User was successfully updated.')
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