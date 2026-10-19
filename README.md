# Foobara HTTP API Command

`foobara-http-api-command` is a gem that quickly encapsulates an external HTTP API call in a Foobara command.

It supports GET requests with query parameters and POST requests with JSON bodies, and parses successful JSON responses.

## Installation

Install the gem directly in your terminal by running the command below:

```sh
gem install foobara-http-api-command
```

Or add it to your application Gemfile:

```ruby
gem "foobara-http-api-command"
```

Then run:

```sh
bundle install
```

## Usage

### Making a GET request

Include `Foobara::HttpApiCommand` in a command class. A GET command builds its request parameters in `build_request_body`. The concern puts them in the URL and returns the parsed JSON by default.

Save the code below in a file such as `search_example.rb`:

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
results # => an Array of Hash results from the API
```

### What each part does

- `include Foobara::HttpApiCommand`: adds the HTTP abilities to the command
- `inputs do .. end`: block which lists the arguments of the command. In this case, a string `query` which is `required`.
- `result [Hash]` says the command should return an array of hashes as the expected output
- `base_url` and `path` together make the address: `https://rubygems.org/api/v1/search.json`
- `build_request_body` sets the request body to `{ query: }`. For a GET request this ends up in the URL as a query parameter.
- `Search.run!(query: "foobara:)` runs the command and returns the parsed JSON.

In the above example, we make a real request to RubyGems.org.

### Running the example

The above example doesn't print anything on its own, so add this line at the end of the file:

```ruby
pp results.first
```

Then run it in the terminal:

```sh
bundle exec ruby search_example.rb
```

You should see a hash describing one search result from RubyGems.org as the output from running the example.

### Make a POST request

To send data instead of asking for it, set `http_method :post`. The request body will then be sent as JSON.

Your command's inputs are not sent automatically. You choose the payload by overriding `build_request_body`. This example uses an echo endpoint ( a service that sends your request back to you), taken from the project's recorded POST test or spec:

```ruby
require "foobara/http_api_command"

class PostExample < Foobara::Command
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

response = PostExample.run!(foo: "bar")
response.fetch("json") # => {"foo"=>"bar"}
```

What is new compared with the GET example:

- `url "https://httpbin.org/post"` gives the complete address in one go, instead of `base_url` plus `path`.
- `http_method :post` makes it a POST
- `http_timeout 120` waits up to 120 seconds for a reply
- `result Hash` says the command returns one hash(not an array of them)
- `response.fetch("json")` reads the `json` part of the reply. This echo service sends your JSON back under that name. 

To see it, add `p response.fetch("json")` at the end of the file and run it with `bundle exec ruby` as before. You should see `{"foo"=>"bar"}`.

### Choosing where and how to send

| Setting | What it does |
| --- | --- |
| `url "https://..."` | The complete address. It can also be a block. |
| `base_url` and `path` | Two halves of the address. Each can also be a block, which runs inside the command instance |
| `http_method :post` | Sends a POST. GET is the default, and only `:get` and `:post` are supported |
| `http_timeout` | Specifies how many seconds to wait for a reply. It sets only the read timeout |

### Things to watch out for

- You supply the slash. `base_url` and `path` are joined as-is, so make sure there's exactly one slash between them. In the GET example, the path starts with `/`
- HTTPS is handled for you. An `https://` address automatically uses TLS signifying an encrypted connection.
- For GET, a request body replaces the URL's query. If the request body is not empty, it replaces any query already in the URL, using `URI.encode_www_form` to encode it.

### Customization

#### Headers

The default `build_request_headers` sets `Content-Type: application/json`. To add a header, override it and call `super` first, which runs the default version, then add yours.

Place the method below inside the command class:

```ruby
def build_request_headers
  super
  request_headers["Accept"] = "application/json"
end
```

#### The result

You can override `build_result` to change parsed `response_body` into whatever your command should return.

### What happens with replies and errors

| What comes back | What you get |
| --- | --- |
| A successful (2xx) response | It's parsed as JSON |
| A response that isn't 2xx | A `RunTimeError` is raised with the response message |
| A successful response with an empty body, or a body that isn't JSON | `JSON::ParserError` is raised |
| A network problem such as a failed connection | The error is raised as is |

Redirects and typed HTTP errors(a seperate error class for each status code are not implemented).

## Contributing

Bug reports and pull requests are welcome at [foobara/http-api-command](https://github.com/foobara/http-api-command).

Contributions in the form of PRs and issues are always welcome.

To work on an existing issue or submit a PR:

1. Fork the repository and clone it to your local machine
2. Run `bundle install` to install dependencies
3. Run `rake` to ensure that everything works as expected before making any changes.
4. Implement your changes
5. Re-run `rake` to make sure that all tests and rubocop pass.
6. Commit your changes, push to GitHub and open a Pull Request for review

## License

This project is licensed under the Mozilla Public License 2.0. For more information about licensing, please see [LICENSE.txt](LICENSE.txt).
