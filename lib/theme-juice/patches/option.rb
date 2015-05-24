# encoding: UTF-8

#
# Monkey patch to not print out reverse bool options on --help
#
# @see https://github.com/erikhuda/thor/issues/417
#
class Thor
  class Option < Argument
    def usage(padding = 0)
      sample = if banner && !banner.to_s.empty?
        "#{switch_name}=#{banner}"
      else
        switch_name
      end

      sample = "[#{sample}]" unless required?

      if aliases.empty?
        (" " * padding) << sample
      else
        "#{aliases.join(', ')}, #{sample}"
      end
    end

    VALID_TYPES.each do |type|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{type}?
          self.type == #{type.inspect}
        end
      RUBY
    end
  end
end
