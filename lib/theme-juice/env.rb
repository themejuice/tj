# encoding: UTF-8

module ThemeJuice
  module Env
    include SingletonHelper

    attr_accessor :vm_box
    attr_accessor :vm_path
    attr_accessor :vm_ip
    attr_accessor :vm_prefix
    attr_accessor :from_path
    attr_accessor :from_srv
    attr_accessor :inside_vm
    attr_accessor :yolo
    attr_accessor :boring
    attr_accessor :no_unicode
    attr_accessor :no_colors
    attr_accessor :no_animations
    attr_accessor :no_landrush
    attr_accessor :no_port_forward
    attr_accessor :verbose
    attr_accessor :quiet
    attr_accessor :robot
    attr_accessor :trace
    attr_accessor :dryrun
    attr_accessor :nginx
    attr_accessor :stage
    attr_accessor :cap
    attr_accessor :archive
    attr_accessor :branch

    def vm_box=(val)
      @vm_box = val || ENV.fetch("TJ_VM_BOX") { "git@github.com:ezekg/theme-juice-vvv.git" }
    end

    def vm_path=(val)
      @vm_path = val || ENV.fetch("TJ_VM_PATH") { File.expand_path("~/tj-vagrant") }
    end

    def vm_ip=(val)
      @vm_ip = val || ENV.fetch("TJ_VM_IP") { "192.168.50.4" }
    end

    def vm_prefix=(val)
      @vm_prefix = val || ENV.fetch("TJ_VM_PREFIX") { "tj-" }
    end

    def from_path=(val)
      @from_path = val || ENV.fetch("TJ_FROM_PATH") { nil }
    end

    def from_srv=(val)
      @from_srv = val || ENV.fetch("TJ_FROM_SRV") { nil }
    end

    def inside_vm=(val)
      @inside_vm = val || ENV.fetch("TJ_INSIDE_VM") { false }
    end

    def yolo=(val)
      @yolo = val || ENV.fetch("TJ_YOLO") { false }
    end

    def robot=(val)
      @robot = val || ENV.fetch("TJ_ROBOT") { false }
    end

    def boring=(val)
      @boring = val || ENV.fetch("TJ_BORING") { robot || false }
    end

    def no_unicode=(val)
      @no_unicode = val || ENV.fetch("TJ_NO_UNICODE") { boring }
    end

    def no_colors=(val)
      @no_colors = val || ENV.fetch("TJ_NO_COLORS") { boring }
    end

    def no_animations=(val)
      @no_animations = val || ENV.fetch("TJ_NO_ANIMATIONS") { boring }
    end

    def no_landrush=(val)
      @no_landrush = val || ENV.fetch("TJ_NO_LANDRUSH") { false }
    end

    def no_port_forward=(val)
      @no_port_forward = val || ENV.fetch("TJ_NO_PORT_FORWARD") { false }
    end

    def verbose=(val)
      @verbose = val || ENV.fetch("TJ_VERBOSE") { false }
    end

    def quiet=(val)
      @quiet = val || ENV.fetch("TJ_QUIET") { false }
    end

    def trace=(val)
      @trace = val || ENV.fetch("TJ_TRACE") { false }
    end

    def dryrun=(val)
      @dryrun = val || ENV.fetch("TJ_DRYRUN") { false }
    end

    def nginx=(val)
      @nginx = val || ENV.fetch("TJ_NGINX") { false }
    end

    extend self
  end
end
