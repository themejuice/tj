# encoding: UTF-8

module ThemeJuice
  module Env
    include SingletonHelper

    attr_accessor :vm_path
    attr_accessor :vm_ip
    attr_accessor :vm_prefix
    attr_accessor :yolo
    attr_accessor :boring
    attr_accessor :no_unicode
    attr_accessor :no_colors
    attr_accessor :no_animations
    attr_accessor :no_landrush
    attr_accessor :verbose
    attr_accessor :dryrun

    def vm_path=(val)
      @vm_path = val ||= ENV.fetch("TJ_VM_PATH") { File.expand_path("~/vagrant") }
    end

    def vm_ip=(val)
      @vm_ip = val ||= ENV.fetch("TJ_VM_IP") { "192.168.50.4" }
    end

    def vm_prefix=(val)
      @vm_prefix = val ||= ENV.fetch("TJ_VM_PREFIX") { "tj-" }
    end

    def yolo=(val)
      @yolo = val ||= ENV.fetch("TJ_YOLO") { false }
    end

    def boring=(val)
      @boring = val ||= ENV.fetch("TJ_BORING") { false }
    end

    def no_unicode=(val)
      @no_unicode = val ||= ENV.fetch("TJ_NO_UNICODE") { boring }
    end

    def no_colors=(val)
      @no_colors = val ||= ENV.fetch("TJ_NO_COLORS") { boring }
    end

    def no_animations=(val)
      @no_animations = val ||= ENV.fetch("TJ_NO_ANIMATIONS") { boring }
    end

    def no_landrush=(val)
      @no_landrush = val ||= ENV.fetch("TJ_NO_LANDRUSH") { false }
    end

    def verbose=(val)
      @verbose = val ||= ENV.fetch("TJ_VERBOSE") { false }
    end

    def dryrun=(val)
      @dryrun = val ||= ENV.fetch("TJ_DRYRUN") { false }
    end

    extend self
  end
end
