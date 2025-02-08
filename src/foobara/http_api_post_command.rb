require_relative "http_api_command"

module Foobara
  module HttpApiPostCommand
    include Concern
    include HttpApiCommand

    def issue_http_request
      uri = URI.parse(api_url)
      self.response = Net::HTTP.post(uri, JSON.generate(request_body), request_headers)
    end
  end
end
