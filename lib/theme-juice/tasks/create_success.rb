# encoding: UTF-8

module ThemeJuice
  module Tasks
    class CreateSuccess < Task

      def initialize(opts = {})
        super

        @vm = Tasks::VMProvision.new(opts)
      end

      def execute
        provision
        success
      end

      private

      def provision
        if @io.agree? "In order to finish creating your project, you need to provision the VM. Do it now?"
          @vm.execute
        else
          @io.notice "Remember, the VM needs to be provisioned before you can use your new site"
        end
      end

      def success
        @io.speak "Successfully created project '#{@project.name}'", :color => :green
        @io.list "Your settings :", :yellow, settings
        @io.open_project @project.url
      end

      def settings
        if @env.verbose
          @env.inspect + @project.inspect
        else
          @project.inspect
        end
      end
    end
  end
end
