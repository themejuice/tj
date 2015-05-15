# encoding: UTF-8

module ThemeJuice
  module Env
    include Helpers

    attr_accessor :vm_path
    attr_accessor :vm_ip
    attr_accessor :vm_prefix
    attr_accessor :no_unicode
    attr_accessor :no_colors
    attr_accessor :no_animations
    attr_accessor :no_landrush
    attr_accessor :boring
    attr_accessor :yolo
    attr_accessor :verbose
    attr_accessor :dryrun

    extend self
  end
end
