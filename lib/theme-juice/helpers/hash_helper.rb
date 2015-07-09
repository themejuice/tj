require "ostruct"

module ThemeJuice
  module HashHelper

    def symbolize_keys
      inject({}) do |acc, (key, value)|
        acc[(key.to_sym rescue key) || key] = value
        acc
      end
    end

    # @TODO This is probably not a good idea...
    def method_missing(method, *args, &block)
      super if method == "symbolize_keys"
      if to_ostruct.respond_to? method
        to_ostruct.send method
      else
        super
      end
    end

    def to_ostruct(acc = self)
      OpenStruct.new acc
    end
  end
end

Hash.send :include, ThemeJuice::HashHelper
