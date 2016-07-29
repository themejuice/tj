module ThemeJuice
  module SingletonHelper

    def inspect
      res = []

      self.instance_variables.each do |k, _|
        str = ""
        str << "#{k[1..-1]}: #{instance_variable_get(k)}"
        str << " (#{instance_variable_get(k).class})" if Env.verbose
        res << str
      end

      res.sort
    end

    def to_h
      hash = {}

      self.instance_variables.each do |k, _|
        hash[k[1..-1]] = instance_variable_get k
      end

      hash
    end
  end
end
