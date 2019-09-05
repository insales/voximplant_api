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
