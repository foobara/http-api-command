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
      # :nocov:
      raise "subclass responsibility"
      # :nocov:
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
