require 'rest_client'

module VoximplantApi
  NO_METHOD_ERROR_CODE = 103
  
  class Error < StandardError
    attr_reader :code

    def initialize(error)
      super error["msg"]
      @code = error["code"]
    end
  end

  class Client

    def initialize(options)
      @account_id = options[:account_id]
      @api_key = options[:api_key]
    end

    def create_child_account(options)
      perform_request_as_parent("AddAccount", options)
    end

    def method_missing(name, *args)
      method_name = name.to_s.split('_').collect(&:capitalize).join
      options = args.first || {}
      perform_request method_name, options

    rescue VoximplantApi::Error => e
      if e.code == NO_METHOD_ERROR_CODE
        raise NoMethodError.new("unknown command '#{method_name}'.")
      else
        raise
      end
    end

    protected

    def auth_params
      {account_id: @account_id,
       api_key: @api_key}
    end

    def parent_auth_params
      {parent_account_id: @account_id,
       parent_account_api_key: @api_key}
    end

    def perform_request(name, params = {})
      params = auth_params.merge params
      self.class.perform_request(name, params)
    end

    def perform_request_as_parent(name, params = {})
      params = parent_auth_params.merge params
      self.class.perform_request(name, params)
    end

    class << self
      def api_basic_url
        "https://api.voximplant.com/platform_api"
      end

      def perform_request(name, params)
        result = JSON.parse (RestClient.post "#{self.api_basic_url}/#{name}", params)
        if result["error"]
          raise Error.new(result["error"])
        end
        result
      end
    end

  end

end
