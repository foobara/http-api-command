require_relative "http_api_command"

module Foobara
  module HttpApiGetCommand
    include Concern
    include HttpApiCommand

    def issue_http_request
      uri = URI(api_url)
      uri.query = URI.encode_www_form(request_body)
      self.response = Net::HTTP.get_response(uri, request_headers)
    end
  end
end
