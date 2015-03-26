require 'rest_client'

module VoximplantApi
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

    def get_info
      perform_request("GetAccountInfo")["result"]
    end

    def get_phone_number_categories(options)
      perform_request("GetPhoneNumberCategories", options)["result"][0]["phone_categories"]
    end

    #options: country_code, phone_category_name
    def get_phone_number_regions(options)
      perform_request("GetPhoneNumberRegions", options)["result"]
    end

    def get_new_phone_numbers(options)
      perform_request("GetNewPhoneNumbers", options)["result"]
    end

    def create_child_account(options)
      perform_request_as_parent("AddAccount", options)
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
        result = JSON.parse (RestClient.get "#{self.api_basic_url}/#{name}", params: params)
        if result["error"]
          raise Error.new(result["error"])
        end
        result
      end
    end

  end

end
