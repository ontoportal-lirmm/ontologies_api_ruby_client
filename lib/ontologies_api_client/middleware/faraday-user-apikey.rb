module Faraday
  ##
  # This middleware causes Faraday to return
  class UserApikey < Faraday::Middleware
    def initialize(app, *arguments)
      super(app)
    end

    def call(env)
      bearer_token = Thread.current[:ontologies_api_client_token]

      if bearer_token
        headers = env[:request_headers]
        headers["Authorization"] = "Bearer #{bearer_token}"
        env[:request_headers] = headers
      else
        user = Thread.current[:session] && Thread.current[:session][:user] ? Thread.current[:session][:user] : nil
        if user
          headers = env[:request_headers]
          headers["Authorization"] = headers["Authorization"] + "&userapikey=" + user.apikey
          env[:request_headers] = headers
        end
      end
      @app.call(env)
    end

  end
end

if Faraday.respond_to?(:register_middleware)
  Faraday.register_middleware user_apikey: Faraday::UserApikey
elsif Faraday::Middleware.respond_to?(:register_middleware)
  Faraday::Middleware.register_middleware user_apikey: Faraday::UserApikey
end