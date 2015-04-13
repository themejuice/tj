# encoding: UTF-8

module ThemeJuice
  module Project
    class << self
      attr_accessor :name
      attr_accessor :location
      attr_accessor :url
      attr_accessor :theme
      attr_accessor :dev_location
      attr_accessor :repository
      attr_accessor :bare
      attr_accessor :skip_repo
      attr_accessor :skip_db
      attr_accessor :use_defaults
      attr_accessor :no_wp
      attr_accessor :no_db
    end
  end
end
