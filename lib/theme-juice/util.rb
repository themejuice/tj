# encoding: UTF-8

module ThemeJuice
  class Util < Thor
    include Thor::Actions

    def initialize(*)
      @env      = Env
      @interact = Interact
      @project  = Project

      super
    end

    def self.destination_root
      @project.location
    end
  end
end
