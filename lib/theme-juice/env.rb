# encoding: UTF-8

module ThemeJuice
  module Env
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

    def inspect
      res = []
      self.instance_variables.each { |k, _| res << "#{k[1..-1]}: #{instance_variable_get(k)}" }
      res.sort
    end

    extend self
  end
end
