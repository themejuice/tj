# encoding: UTF-8

module ThemeJuice
  module Tasks
    class List < Task

      def initialize(opts = {})
        super
      end

      def list(prop)
        @io.error "Cannot list '#{prop}'", NotImplementedError unless self.respond_to? prop

        if self.send(prop).empty?
          @io.log "Nothing to list"
        else
          @io.list "#{prop.capitalize}:", :green, self.send(prop)
        end
      end

      def projects
        res = []

        Dir["#{@project.vm_root}/*"].each do |f|
          name = File.basename f

          if File.directory?(f) && name.include?(@env.vm_prefix)
            res << name.gsub(/(#{@env.vm_prefix})/, "")
          end
        end

        res
      end

      def urls
        res = []
        ls  = `vagrant landrush ls`

        unless ls.nil?
          ls.gsub(/\s+/m, " ").split(" ").each do |url|
            res << url if /(\.dev)/ =~ url
          end
        end

        res
      end
    end
  end
end
