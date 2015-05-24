# encoding: UTF-8

module ThemeJuice
  module Project
    include SingletonHelper

    attr_accessor :name
    attr_accessor :location
    attr_accessor :url
    attr_accessor :theme
    attr_accessor :vm_root
    attr_accessor :vm_location
    attr_accessor :vm_srv
    attr_accessor :vm_restart
    attr_accessor :repository
    attr_accessor :db_host
    attr_accessor :db_name
    attr_accessor :db_user
    attr_accessor :db_pass
    attr_accessor :db_import
    attr_accessor :db_drop
    attr_accessor :bare
    attr_accessor :skip_repo
    attr_accessor :skip_db
    attr_accessor :use_defaults
    attr_accessor :no_wp
    attr_accessor :no_db

    extend self
  end
end
