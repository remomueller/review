class AuthenticationsController < ApplicationController
  def index
    @authentications = current_user.authentications if current_user
  end

  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

  def failure
    redirect_to new_user_session_path, :alert => params[:message].blank? ? nil : params[:message].humanize
  end

  def create
    logger.info "request #{request.env["omniauth.auth"].inspect}"
    omniauth = request.env["omniauth.auth"]
    logger.info "omniauth: #{omniauth.inspect}"
    
    if omniauth
    
      omniauth['uid'] = omniauth['user_info']['email'] if omniauth['provider'] == 'google_apps' and omniauth['user_info']
      authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
      logger.info "OMNI AUTH INFO: #{omniauth.inspect}"
      omniauth['user_info']['email'] = omniauth['extra']['user_hash']['email'] if omniauth['user_info'] and omniauth['user_info']['email'].blank? and omniauth['extra'] and omniauth['extra']['user_hash']
      if authentication
        session["user_return_to"] = request.env["action_dispatch.request.unsigned_session_cookie"]["user_return_to"] if request.env and request.env["action_dispatch.request.unsigned_session_cookie"] and request.env["action_dispatch.request.unsigned_session_cookie"]["user_return_to"] and session["user_return_to"].blank?
        flash[:notice] = "Signed in successfully." if authentication.user.active_for_authentication?
        sign_in_and_redirect(:user, authentication.user)
      elsif current_user
        current_user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])
        redirect_to authentications_path, :notice => "Authentication successful."
      else
        user = User.new(params[:user])
        user.apply_omniauth(omniauth)
        if user.save
          session["user_return_to"] = request.env["action_dispatch.request.unsigned_session_cookie"]["user_return_to"] if request.env and request.env["action_dispatch.request.unsigned_session_cookie"] and request.env["action_dispatch.request.unsigned_session_cookie"]["user_return_to"] and session["user_return_to"].blank?
          flash[:notice] = "Signed in successfully." if user.active_for_authentication?
          sign_in_and_redirect(:user, user)
        else
          session[:omniauth] = omniauth.except('extra')
          redirect_to new_user_registration_path
        end
      end

    else
      request.env.keys.each do |key|
        logger.info "request.env[#{key}]: #{request.env[key]}"
      end
      redirect_to authentications_path, :alert => "Authentication not successful."
    end
    
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    flash[:notice] = "Successfully destroyed authentication."
    redirect_to authentications_path
  end
end