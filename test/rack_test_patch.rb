module Rack
  module Test
    class Session
      def env_for(path, env)
        uri = URI.parse(path)
        uri.path = "/#{uri.path}" unless uri.path[0] == ?/
        uri.host ||= @default_host

        env["HTTP_HOST"] ||= [uri.host, uri.port].compact.join(":")

        env = default_env.merge(env)

        env.update("HTTPS" => "on") if URI::HTTPS === uri
        env["HTTP_X_REQUESTED_WITH"] = "XMLHttpRequest" if env[:xhr]

        # TODO: Remove this after Rack 1.1 has been released.
        # Stringifying and upcasing methods has be commit upstream
        env["REQUEST_METHOD"] ||= env[:method] ? env[:method].to_s.upcase : "GET"

        if env["REQUEST_METHOD"] == "GET"
          params = env[:params] || {}
          params = parse_nested_query(params) if params.is_a?(String)
          
          # HERE IS THE PATCH!!!!!!!!
          # 
          # All this for that: the original parsed the querys string params,
          # and rebuilt them, instead of assuming people know what they mean
          # when they make a URL and leaving well enough alone!
          uri.query = (uri.query || '') + build_nested_query(params)
          # 
          # THAT WAS THE PATCH!!!!!!!!
        elsif !env.has_key?(:input)
          env["CONTENT_TYPE"] ||= "application/x-www-form-urlencoded"

          if env[:params].is_a?(Hash)
            if data = build_multipart(env[:params])
              env[:input] = data
              env["CONTENT_LENGTH"] ||= data.length.to_s
              env["CONTENT_TYPE"] = "multipart/form-data; boundary=#{MULTIPART_BOUNDARY}"
            else
              env[:input] = params_to_string(env[:params])
            end
          else
            env[:input] = env[:params]
          end
        end

        env.delete(:params)

        if env.has_key?(:cookie)
          set_cookie(env.delete(:cookie), uri)
        end

        Rack::MockRequest.env_for(uri.to_s, env)
      end
    end
  end
end
  