require "uri"
require "net/http"

module Foobara
  module HttpApiCommand
    include Concern
    include Concerns::Url

    def execute
      build_request_body
      build_request_headers
      issue_http_request
      parse_response
      build_result
    end

    attr_accessor :request_body, :request_headers, :response, :response_body

    def build_request_body
      self.request_body = {}
    end

    def build_request_headers
      self.request_headers = {
        "Content-Type" => "application/json"
      }
    end

    def issue_http_request
      case self.class.http_method
      when :get
        uri = URI(api_url)
        uri.query = URI.encode_www_form(request_body)
        self.response = Net::HTTP.get_response(uri, request_headers)
      when :post
        uri = URI.parse(api_url)
        self.response = Net::HTTP.post(uri, JSON.generate(request_body), request_headers)
      else
        # :nocov:
        raise "Unknown http method #{self.class.http_method}"
        # :nocov:
      end
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
  end
end
