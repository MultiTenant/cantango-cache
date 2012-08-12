module CanTango
  module Cache
    module Stores
      class MonetaStore < BaseStore
        include Singleton

        attr_reader :options

        def configure_with options = {}
          @options ||= options
          @type ||= options[:type] || CanTango.config.cache.store.default_type
        end

        def load! key
          cache[key]
        end

        def save! key, rules
          cache.store key, rules
        end

        def delete key
          cache.delete key
        end

        def cache
          @cache ||= begin
            moneta = eval(factory_statement)
            moneta.clear
            moneta
          end
        end

        def factory_statement
          %{
            ::Moneta::Builder.build do
              #{run_adapter}
            end
          }
        end

        def run_adapter
          case type.to_sym
          when :yaml
            yaml_adapter
          else
            simple_adapter
          end
        end

        def yaml_adapter
          "run #{adapter}, #{options}"
        end

        def simple_adapter
          "run #{adapter}"
        end

        def type
          (@type == :yaml) ? :YAML : @type
        end

        def adapter
          require "moneta/adapters/#{type}"
          @adapter = "Moneta::Adapters::#{type.to_s.camelize}".constantize
        end
      end
    end
  end
end