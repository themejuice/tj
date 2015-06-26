require "ostruct"

module ThemeJuice
  module HashHelper

    def symbolize_keys
      inject({}) do |acc, (k, v)|
        key = String === k ? k.to_sym : k
        value = Hash === v ? v.symbolize_keys : v
        acc[key] = value
        acc
      end
    end

    # @TODO This is probably not a good idea
    def method_missing(method)
      if to_ostruct.respond_to? method
        to_ostruct.send method
      else
        super
      end
    end

    def to_ostruct(acc = self, opts = {})
      if opts[:recursive]
        case acc
        when Hash
          OpenStruct.new Hash[acc.map { |k, v| [k, to_ostruct(v)] } ]
        when Array
          acc.map { |x| to_ostruct(x) }
        else
          acc
        end
      else
        OpenStruct.new acc
      end
    end
  end
end

Hash.send :include, ThemeJuice::HashHelper
