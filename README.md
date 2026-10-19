# Foobara::HttpApiCommand

`foobara-http-api-command` encapsulates an external HTTP API call in a Foobara command.

## Installation

Add `foobara-http-api-command` to your Gemfile or .gemspec file and `bundle install`.

Or even just `gem install foobara-http-api-command` if playing with it directly in the scripts.

## Usage

### Making a GET request

Require the library and include `Foobara::HttpApiCommand` in a command class.

```ruby
require "foobara/http_api_command"

class Search < Foobara::Command
  include Foobara::HttpApiCommand

  inputs do
    query :string, :required
  end

  result [Hash]

  base_url "https://rubygems.org/api/v1"
  path "/search.json"

  def build_request_body
    self.request_body = { query: }
  end
end

results = Search.run!(query: "foobara")
pp results.first # => an Array of Hash results from the API
```

### Making a POST request

To make a POST request, set `http_method :post`. The request body will then be sent as JSON.

```ruby
require "foobara/http_api_command"

class Post < Foobara::Command
  include Foobara::HttpApiCommand

  inputs do
    foo :string, :required
  end

  result Hash
  url "https://httpbin.org/post"
  http_method :post
  http_timeout 120

  def build_request_body
    self.request_body = { foo: }
  end
end

response = Post.run!(foo: "bar")
pp response.fetch("json") # => {"foo"=>"bar"}
```

## Contributing

Contributions are welcome on Github at [foobara/http-api-command](https://github.com/foobara/http-api-command).

To work on an existing issue or submit a PR:

1. Fork the repository and clone it to your local machine
2. Run `bundle install` to install dependencies
3. Run `rake` to ensure that everything works as expected before making any changes
4. Implement your changes
5. Re-run `rake` to make sure that all tests and Rubocop pass
6. Commit your changes, push to GitHub and open a Pull Request for review

## License

This project is licensed under the MPL-2.0 license. Please see [LICENSE.txt](LICENSE.txt) for more information.
