module OmniAuth
  module Strategies
    class LDAP
      def perform
        # Rails.logger.debug "PERFORM! #{request.POST.inspect} #{@adaptor.inspect}"
        begin
          begin
            request.POST['username'] = request.POST['domain'].to_s + '\\' + request.POST['username'] unless request.POST['domain'].blank?
            @adaptor.bind(:bind_dn => request.POST['username'], :password => request.POST['password'])
          rescue Exception => e
            Rails.logger.info "failed to bind with the default credentials: " + e.message
            return fail!(:invalid_credentials, e)
          end
          
          @ldap_user_info = @adaptor.search(:base => @adaptor.base, :filter => Net::LDAP::Filter.eq(@adaptor.uid, request.POST['username'].split('\\').last.to_s),:limit => 1)
          @ldap_user_info.each do |key, val|
            @ldap_user_info[key] = val.first if val.class == Array and val.size == 1
          end
          Rails.logger.debug "LDAP USER INFO #{@ldap_user_info.inspect}"
          @user_info = self.class.map_user(@@config, @ldap_user_info)
          Rails.logger.debug "USER INFO #{@user_info.inspect}"
          @env['REQUEST_METHOD'] = 'GET'
          @env['PATH_INFO'] = "#{OmniAuth.config.path_prefix.split('/').last}/#{name}/callback"
          @env['omniauth.auth'] = {'provider' => 'ldap', 'uid' => @user_info['uid'], 'user_info' => @user_info}
          Rails.logger.debug "ENV: " + @env.inspect

        rescue Exception => e
          Rails.logger.info "Exception #{e.inspect}"
          return fail!(:invalid_credentials, e)
        end
        
        call_app!
      end
      
      def initialize(app, title, options = {})
        super(app, options.delete(:name) || :ldap)
        @title = title
        @domain = options[:domain]
        @adaptor = OmniAuth::Strategies::LDAP::Adaptor.new(options)
        Rails.logger.info "Domain: #{@domain}"
      end
      
      def get_credentials
        domain = @domain
        OmniAuth::Form.build(@title) do
          text_field 'Login', 'username'
          password_field 'Password', 'password'
          hidden_field 'domain', domain
        end.to_response
      end
      
      def self.map_user mapper, object
		  	user = {}
		    mapper.each do |key, value|
		      case value
		        when String
		          if object[value.downcase.to_sym]
		            if object[value.downcase.to_sym].kind_of?(Array)
		              user[key] = object[value.downcase.to_sym].join(', ')
	              else
		              user[key] = object[value.downcase.to_sym].to_s 
	              end
	            end
		        when Array
              # value.each {|v| (user[key] = object[v.downcase.to_sym].to_s; break;) if object[v.downcase.to_sym]}
              value.each {|v| (user[key] = object[v.downcase.to_sym].join(', '); break;) if object[v.downcase.to_sym]}
		        when Hash
		        	value.map do |key1, value1|
			        	pattern = key1.dup
			        	value1.each_with_index do |v,i|
			          	part = '';
			          	v.each {|v1| (part = object[v1.downcase.to_sym].to_s; break;) if object[v1.downcase.to_sym]}
			        		pattern.gsub!("%#{i}",part||'') 
			        	end	
			        	user[key] = pattern
		       		end
		        end
		      end
		    user
		  end
      
    end
  end
end

module OmniAuth
  module Strategies
    # OmniAuth strategy for connecting via OpenID. This allows for connection
    # to a wide variety of sites, some of which are listed [on the OpenID website](http://openid.net/get-an-openid/).
    class OpenID
      
      # def dummy_app
      #   Rails.logger.debug "dummy_app id #{identifier} return_to #{callback_url}"
      #   lambda{|env| [401, {"WWW-Authenticate" => Rack::OpenID.build_header(
      #     :identifier => identifier,
      #     :trust_root => mod_callback_url + "&_method=post", # SITE_URL,
      #     :return_to => mod_callback_url,
      #     :required => @options[:required],
      #     :optional => @options[:optional],
      #     :method => 'post'
      #   )}, []]}
      # end
      # 
      # def callback_phase
      #   env['REQUEST_METHOD'] = 'GET'
      #   
      #   Rails.logger.info "RACK OPENID RETURN_TO: " + env.keys.inspect
      #   
      #   openid = Rack::OpenID.new(lambda{|env| [200,{},[]]}, @store)
      #   # Rails.logger.info "OPENID: #{env.inspect}"
      #   status, headers, body = openid.call(env)
      #   Rails.logger.info "Status #{status}, Headers, #{headers}, Body #{body}"
      #   Rails.logger.info "OPENID RESPONSE: #{env['rack.openid.response'].message}"
      #   @openid_response = env.delete('rack.openid.response')
      #   if @openid_response && @openid_response.status == :success
      #     super
      #   else
      #     fail!(:invalid_credentials)
      #   end
      # end
      
      
      # def start
      #   openid = Rack::OpenID.new(dummy_app, @store)
      #   response = openid.call(env)
      #   
      #   Rails.logger.info "Start Response: #{env.inspect}"
      #   
      #   case env['rack.openid.response']
      #   when Rack::OpenID::MissingResponse, Rack::OpenID::TimeoutResponse
      #     fail!(:connection_failed)
      #   else
      #     response
      #   end
      # end
      
      # def callback_url
      #   uri = URI.parse(request.url)
      #   uri.path += '/callback'
      #   uri.to_s
      # end
      
      def mod_callback_url
        uri = URI.parse(request.url)
        uri.path += '/callback'
        "#{SITE_URL}/auth#{uri.to_s.split('/auth').last}"
      end
    end
  end
end

module OmniAuth
  
  module Strategy
    
    def full_host
      # uri = URI.parse(request.url)
      # uri.path = ''
      # uri.query = nil
      # uri.to_s
      
      s_uri = URI.parse(SITE_URL)
      s_uri.path = ''
      s_uri.query = nil
      Rails.logger.info "FULL_HOST: #{s_uri.to_s}"
      s_uri.to_s
    end
    
    def callback_url
      full_host + "#{OmniAuth.config.path_prefix}/#{name}/callback"
    end
  end
end

module OmniAuth
  class Form
    def hidden_field(name, value)
      Rails.logger.info "Name: '#{name}' Value: '#{value}'"
      @html << "\n<input type='hidden' id='#{name}' name='#{name}' value='#{value}'/>"
      self
    end
  end
end


# module Rack
#   # Rack::Request provides a convenient interface to a Rack
#   # environment.  It is stateless, the environment +env+ passed to the
#   # constructor will be directly modified.
#   #
#   #   req = Rack::Request.new(env)
#   #   req.post?
#   #   req.params["data"]
#   #
#   # The environment hash passed will store a reference to the Request object
#   # instantiated so that it will only instantiate if an instance of the Request
#   # object doesn't already exist.
# 
#   class Request
# 
#     def ip
#       Rails.logger.info "IP IP IP IP IP"
#       # if addr = @env['HTTP_X_FORWARDED_FOR']
#       #   Rails.logger.info "Parsing from HTTP_X_FORWARDED_FOR! #{(addr.split(',').grep(/\d\./).first || @env['REMOTE_ADDR']).to_s.strip}"
#       #   (addr.split(',').grep(/\d\./).first || @env['REMOTE_ADDR']).to_s.strip
#       # else
#         Rails.logger.info "Using REMOTE_ADDR how boring... #{@env['REMOTE_ADDR']}"
#         @env['REMOTE_ADDR']
#       # end
#     end
#   end
# end

