module ThemeJuice
  module Helpers
    def inspect
      res = []
      self.instance_variables.each { |k, _| res << "#{k[1..-1]}: #{instance_variable_get(k)}" }
      res.sort
    end
  end
end
