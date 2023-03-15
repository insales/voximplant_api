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
    attr_reader :private_key, :private_key_id, :account_id

    def initialize(options)
      @account_id = options[:account_id]
      @api_key = options[:api_key]
      @private_key = options[:private_key]
      @private_key_id = options[:private_key_id]
    end

    def create_child_account(options)
      perform_request_as_parent("AddAccount", options)
    end

    def generate_contractor_invoice(options)
      RestClient.post("#{self.class.api_basic_url}/GenerateContractorInvoice", auth_params.merge(options))
    end

    def method_missing(name, *args)
      options = args.first || {}
      name_words = name.to_s.split('_')
      if name_words.first == "each"
        return enum_for(name, *args) unless block_given?
        method_name = name_words[1..-1].collect(&:capitalize).join
        perform_request_each method_name, options do |x|
          yield x
        end
      else
        method_name = name_words.collect(&:capitalize).join
        perform_request method_name, options
      end

    rescue VoximplantApi::Error => e
      if e.code == NO_METHOD_ERROR_CODE
        raise NoMethodError.new("unknown command '#{method_name}'.")
      else
        raise
      end
    end

    protected

    def build_token
      ts = Time.now.to_i
      payload = { iss: account_id, iat: ts - 5, exp: ts + 64 }
      JWT.encode(payload,
        OpenSSL::PKey::RSA.new(private_key),
        'RS256',
        kid: private_key_id, typ: 'JWT')
    end

    def auth_params
      {account_id: @account_id,
       api_key: @api_key}
    end

    def parent_auth_params
      {parent_account_id: @account_id,
       parent_account_api_key: @api_key}
    end

    def perform_request(name, params = {})
      if private_key
        self.class.perform_api_request(name, params.merge(account_id: @account_id), auth_headers)
      else
        self.class.perform_request(name, auth_params.merge(params))
      end
    end

    def auth_headers
      { Authorization: "Bearer #{build_token}" }
    end

    def perform_request_each(name, params = {})
      offset = params[:offset] || 0
      per_page = [params[:count] || 100, 100].min
      begin
        result = perform_request(name, params.merge(offset: offset, count: per_page))
        count = result["count"]
        offset += count
        total_count = result["total_count"]
        result["result"].each do |obj|
          yield obj
        end
      end while offset < total_count
    end

    def perform_request_as_parent(name, params = {})
      if private_key
        self.class.perform_api_request(name, params.merge(account_id: @account_id), auth_headers)
      else
        self.class.perform_request(name, parent_auth_params.merge(params))
      end
    end

    class << self
      def api_basic_url
        "https://api.voximplant.com/platform_api"
      end

      def perform_api_request(name, params, headers = {})
        params = params.merge(cmd: name)
        result = JSON.parse (RestClient.post "#{self.api_basic_url}", params, headers)
        if result["error"]
          raise Error.new(result["error"])
        end
        result
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
