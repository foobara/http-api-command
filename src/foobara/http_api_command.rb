require "uri"
require "net/http"
require "json"

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
      request = case self.class.http_method
                when :get
                  uri = if request_body.empty?
                          api_uri_object
                        else
                          api_uri_object.dup.tap do |new_uri|
                            new_uri.query = URI.encode_www_form(request_body)
                          end
                        end

                  Net::HTTP::Get.new(uri.request_uri, request_headers)
                when :post
                  Net::HTTP::Post.new(api_uri_object.request_uri, request_headers).tap do |post|
                    post.body = JSON.generate(request_body)
                  end
                else
                  # simplecov:disable
                  raise "Unknown http method #{self.class.http_method}"
                  # simplecov:enable
                end

      self.response = net_http.request(request)
    end

    def build_result
      response_body
    end

    def parse_response
      json = if response.is_a?(Net::HTTPSuccess)
               response.body
             else
               # simplecov:disable
               raise "Could not successfully hit #{api_url}: " \
                     "#{response.code} #{response.message}"
               # simplecov:enable
             end

      self.response_body = JSON.parse(json)
    end
  end
end
