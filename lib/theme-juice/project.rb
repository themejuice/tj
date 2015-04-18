# encoding: UTF-8

module ThemeJuice
  module Project
    attr_accessor :name
    attr_accessor :location
    attr_accessor :url
    attr_accessor :theme
    attr_accessor :vm_location
    attr_accessor :repository
    attr_accessor :db_host
    attr_accessor :db_name
    attr_accessor :db_user
    attr_accessor :db_pass
    attr_accessor :bare
    attr_accessor :skip_repo
    attr_accessor :skip_db
    attr_accessor :use_defaults
    attr_accessor :no_wp
    attr_accessor :no_db

    def inspect
      res = []
      self.instance_variables.each { |k, _| res << "#{k[1..-1]}: #{instance_variable_get(k)}" }
      res
    end

    extend self
  end
end
