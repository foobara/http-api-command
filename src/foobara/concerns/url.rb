module Foobara
  module HttpApiCommand
    module Concerns
      module Url
        include Concern

        def api_url
          @api_url ||= self.class.compute_api_url(self)
        end

        inherited_overridable_class_attr_accessor :foobara_base_url_block,
                                                  :foobara_base_url,
                                                  :foobara_path,
                                                  :foobara_url_block,
                                                  :foobara_url,
                                                  :foobara_http_method

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

          def path(path = nil)
            if path
              self.foobara_path = path
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

          def compute_api_url(command)
            if foobara_url
              foobara_url
            elsif foobara_url_block
              command.instance_eval(&foobara_url_block)
            elsif foobara_path
              base = if foobara_base_url
                       foobara_base_url
                     elsif foobara_base_url_block
                       command.instance_eval(&foobara_base_url_block)
                     else
                       # :nocov:
                       raise "Not able to determine the api url. Did you remember to call .url or .path and .base_url?"
                       # :nocov:
                     end

              "#{base}#{foobara_path}"
            else
              # :nocov:
              raise "Not able to determine the api url. Did you remember to call .url or .path and .base_url?"
              # :nocov:
            end
          end
        end
      end
    end
  end
end
