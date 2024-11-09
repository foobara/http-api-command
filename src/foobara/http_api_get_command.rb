require "uri"
require "net/http"

module Foobara
  module HttpApiGetCommand
    include Concern

    def execute
      build_request_body
      build_request_headers
      issue_http_request
      parse_response
      build_result
    end

    attr_accessor :request_body, :request_headers, :response, :response_body

    def api_url
      @api_url ||= instance_eval(&self.class.foobara_url_block)
    end

    def build_request_body
      self.request_body = {}
    end

    def build_request_headers
      self.request_headers = {
        "Content-Type" => "application/json"
      }
    end

    def issue_http_request
      uri = URI(api_url)
      uri.query = URI.encode_www_form(request_body)
      self.response = Net::HTTP.get_response(uri, request_headers)
    end

    def build_result
      response_body
    end

    def parse_response
      json = if response.is_a?(Net::HTTPSuccess)
               response.body
             else
               # :nocov:
               raise "Could not successfully hit #{api_url}: " \
                     "#{response.code} #{response.message}"
               # :nocov:
             end

      self.response_body = JSON.parse(json)
    end

    module ClassMethods
      attr_accessor :foobara_url_block

      def url(string = nil, &block)
        self.foobara_url_block = if block_given?
                                   block
                                 else
                                   -> { string }
                                 end
      end
    end
  end
end
