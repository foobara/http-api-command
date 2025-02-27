module Foobara
  module HttpApiCommand
    module Concerns
      module Url
        include Concern

        def net_http
          @net_http ||= self.class.compute_http(self)
        end

        def api_url
          @api_url ||= self.class.compute_api_url(self)
        end

        def api_uri_object
          @api_uri_object ||= self.class.compute_uri_object(self)
        end

        inherited_overridable_class_attr_accessor :foobara_base_url_block,
                                                  :foobara_base_url,
                                                  :foobara_path,
                                                  :foobara_path_block,
                                                  :foobara_url_block,
                                                  :foobara_url,
                                                  :foobara_http_method,
                                                  :foobara_http_timeout

        module ClassMethods
          def http_method(method = nil)
            if method
              self.foobara_http_method = method
            else
              foobara_http_method || :get
            end
          end

          def base_url(url = nil, &block)
            if block_given?
              unless url.nil?
                # :nocov:
                raise ArgumentError, "Cannot specify both url and block"
                # :nocov:
              end

              self.foobara_base_url_block = block
            elsif url
              self.foobara_base_url = url
            else
              # :nocov:
              raise ArgumentError, "No base url specified"
              # :nocov:
            end
          end

          def path(path = nil, &block)
            if block_given?
              unless path.nil?
                # :nocov:
                raise ArgumentError, "Cannot specify both path and block"
                # :nocov:
              end

              self.foobara_path_block = block
            elsif path
              self.foobara_path = path
            else
              # :nocov:
              raise ArgumentError, "No path specified"
              # :nocov:
            end
          end

          def url(uri = nil, &block)
            if block_given?
              unless uri.nil?
                # :nocov:
                raise ArgumentError, "Cannot specify both uri and block"
                # :nocov:
              end

              self.foobara_url_block = block
            elsif uri
              self.foobara_url = uri
            else
              # :nocov:
              raise ArgumentError, "Must give either a url or a block that returns  url"
              # :nocov:
            end
          end

          def http_timeout(timeout = nil)
            if timeout
              self.foobara_http_timeout = timeout
            else
              foobara_http_timeout
            end
          end

          def compute_uri_object(command)
            return @compute_uri_object if @compute_uri_object

            uri = URI(compute_api_url(command))

            unless foobara_base_url_block || foobara_path_block || foobara_url_block
              @compute_uri_object = uri
            end

            uri
          end

          def compute_api_url(command)
            return @compute_api_url if @compute_api_url

            url = if foobara_url
                    foobara_url
                  elsif foobara_url_block
                    command.instance_eval(&foobara_url_block)
                  else
                    path = if foobara_path
                             foobara_path
                           elsif foobara_path_block
                             command.instance_eval(&foobara_path_block)
                           end

                    base = if foobara_base_url
                             foobara_base_url
                           elsif foobara_base_url_block
                             command.instance_eval(&foobara_base_url_block)
                           else
                             # :nocov:
                             raise "Not able to determine the api url. " \
                                   "Did you remember to call .url or .path and .base_url?"
                             # :nocov:
                           end

                    "#{base}#{path}"
                  end

            unless foobara_base_url_block || foobara_path_block || foobara_url_block
              @compute_api_url = url
            end

            url
          end

          def compute_http(command)
            return @net_http if @net_http

            uri = URI(command.api_url)
            computed_http = Net::HTTP.new(uri.host, uri.port).tap do |http|
              http.use_ssl = uri.scheme == "https"
              if http_timeout
                http.read_timeout = http_timeout
              end
            end

            unless foobara_base_url_block || foobara_path_block || foobara_url_block
              @net_http = computed_http
            end

            computed_http
          end
        end
      end
    end
  end
end
