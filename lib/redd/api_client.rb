# frozen_string_literal: true

require_relative 'client'
require_relative 'error'
require_relative 'utilities/error_handler'
require_relative 'utilities/rate_limiter'
require_relative 'utilities/unmarshaller'

module Redd
  # The class for API clients.
  class APIClient < Client
    # The endpoint to make API requests to.
    API_ENDPOINT = 'https://oauth.reddit.com'

    # @return [APIClient] the access the client uses
    attr_reader :access

    # Create a new API client from an auth strategy.
    # @param auth [AuthStrategies::AuthStrategy] the auth strategy to use
    # @param endpoint [String] the API endpoint
    # @param user_agent [String] the user agent to send
    # @param limit_time [Integer] the minimum number of seconds between each request
    # @param auto_retry [Boolean] whether to retry requests that may be successful if retried
    # @param auto_login [Boolean] (for script and userless) automatically authenticate if not done
    #   so already
    # @param auto_refresh [Boolean] (for script and userless) automatically refresh access token if
    #   nearing expiration
    def initialize(auth, endpoint: API_ENDPOINT, user_agent: USER_AGENT, limit_time: 1,
                   auto_retry: true, auto_login: true, auto_refresh: true)
      super(endpoint: endpoint, user_agent: user_agent)

      @auth   = auth
      @access = nil
      @error_handler = Utilities::ErrorHandler.new
      @rate_limiter  = Utilities::RateLimiter.new(limit_time)
      @unmarshaller  = Utilities::Unmarshaller.new(self)
      @auto_retry    = auto_retry

      # FIXME: ugh, hard dependencies
      can_auto      = auth.is_a?(AuthStrategies::Script) || auth.is_a?(AuthStrategies::Userless)
      @auto_login   = can_auto && auto_login
      @auto_refresh = can_auto && auto_refresh
    end

    # Authenticate the client using the provided auth.
    # @return [Access] the access returned by the strategy
    def authenticate(*args)
      @access = @auth.authenticate(*args)
    end

    # Refresh the access currently in use.
    # @return [Access] the newly refreshed access
    def refresh(*args)
      @access = @auth.refresh(*args)
    end

    # Revoke the current access and remove it from the client.
    def revoke
      @auth.revoke(@access)
      @access = nil
    end

    def unmarshal(object)
      @unmarshaller.unmarshal(object)
    end

    def model(verb, path, params = {})
      # XXX: make unmarshal explicit in methods?
      unmarshal(send(verb, path, params).body)
    end

    private

    # Makes sure a valid access is present, raising an error if nil
    def ensure_access_is_valid
      # Authenticate first if auto_login is enabled
      authenticate if @access.nil? && @auto_login
      # Refresh access if auto_refresh is enabled
      refresh if @access.expired? && @auto_refresh
      # Fuck it, panic
      raise 'client access is nil, try calling #authenticate' if @access.nil?
    end

    def connection
      super.auth("Bearer #{@access.access_token}")
    end

    # Makes a request, ensuring not to break the rate limit by sleeping.
    # @see Client#request
    def request(verb, path, params: {}, form: {})
      # Make sure @access is populated by a valid access
      ensure_access_is_valid
      # Setup base API params and make request
      api_params = { api_type: 'json', raw_json: 1 }.merge(params)
      response = @rate_limiter.after_limit { super(verb, path, params: api_params, form: form) }
      # Check for errors in the returned response
      err = @error_handler.check_error(response)
      raise err unless err.nil?
      # All done, return the response
      response
    rescue Redd::ServerError => e
      # FIXME: auto_retry might loop forever if issue is on reddit's end?
      retry if @auto_retry
      raise e
    end

    # Raise an error if one was detected in the response.
    # @param response [Response] the response object to check
    # @raise ResponseError
    def check_errors(response)
      API_ERRORS.each { |klass| raise klass.new(response) if klass.error?(response) }
    end
  end
end