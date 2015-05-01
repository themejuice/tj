# encoding: UTF-8

module ThemeJuice
  module Tasks
    class List < Task

      def initialize(opts = {})
        super

        @project.vm_root     = vm_root
        @project.vm_location = vm_location
      end

      def list(prop)
        @io.error "Cannot list '#{prop}'" unless self.respond_to? prop

        if self.send(prop).empty?
          @io.log "Nothing to list"
        else
          @io.list "Projects :", :green, self.send(prop)
        end
      end

      def projects
        res = []

        Dir["#{@project.vm_root}/*"].each do |f|
          if File.directory?(f) && f.include?(@env.vm_prefix)
            res << File.basename(f).gsub(/(#{@env.vm_prefix})/, "")
          end
        end

        res
      end

      def urls
        res = []

        output = @util.run "vagrant landrush ls", { :verbose => @env.verbose,
          :capture => true } unless @env.no_landrush

        unless output.nil?
          output.gsub(/\s+/m, " ").split(" ").each do |url|
            res << url if /(\.dev)/ =~ url
          end
        end

        res
      end
    end
  end
end
