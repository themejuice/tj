# encoding: UTF-8

module ThemeJuice
  module Tasks
    class CreateSuccess < Task

      def initialize(opts = {})
        super

        @vm_provision = Tasks::VMProvision.new(opts)
      end

      def execute
        provision_vm
        success
      end

      private

      def provision_vm
        if @io.agree? "In order to finish creating your project, you need to provision the VM. Do it now?"
          @vm_provision.execute
        else
          @io.notice "Remember, the VM needs to be provisioned before you can use your new site"
        end
      end

      def success
        @io.speak "Successfully created project '#{@project.name}'", :color => :green
        @io.list "Your settings :", :yellow, settings
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
