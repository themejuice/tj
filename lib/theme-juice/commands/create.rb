# encoding: UTF-8

module ThemeJuice
  module Commands
    class Create < Command

      def initialize(opts = {})
        super

        @project.name        = @opts.fetch("name") { name }
        @project.location    = @opts.fetch("location") { location }
        @project.url         = @opts.fetch("url") { url }
        @project.theme       = @opts.fetch("theme") { theme }
        @project.vm_location = vm_location
        @project.inspect

        runner do |tasks|
          tasks << Tasks::VVV.new
        end
      end

      def do
        @interact.log "Running method 'do' for create command"
        @tasks.each { |task| task.do }
      end

      def undo
        @interact.log "Running method 'undo' for create command"
        @tasks.each { |task| task.undo }
      end

      private

      def name
        if @env.yolo
          name =  Faker::Internet.domain_word
        else
          name = @interact.prompt "What's the project name? (letters, numbers and dashes only)"
        end

        valid_name? name

        name
      end

      def valid_name?(name)
        if name.empty?
          @interact.error "Project name '#{name}' is invalid or empty. Aborting mission."
        end

        "#{name}".match /[^0-9A-Za-z.\-]/ do |char|
          @interact.error "Project name contains an invalid character '#{char}'. This name is used for creating directories, so that's not gonna work. Aborting mission."
        end

        true
      end

      def clean_name
        "#{@project.name}".gsub(/[^\w]/, "_")[0..10]
      end

      def location
        path = "#{Dir.pwd}/"

        if @project.use_defaults
          location = File.expand_path path
        else
          location = File.expand_path @interact.prompt("Where do you want to setup the project?", :default => path, :path => true)
        end

        location
      end

      def url
        if @project.use_defaults
          url = "#{@project.name}.dev"
        else
          url = @interact.prompt "What do you want the development url to be? (this should end in '.dev')", :default => "#{@project.name}.dev"
        end

        valid_url? url

        url
      end

      def valid_url?(url)
        unless "#{url}".match /(.dev)$/
          @interact.error "Your development url '#{url}' doesn't end with '.dev'. This is used internally by Landrush, so that's not gonna work. Aborting mission."
        end

        true
      end

      def theme
        return false if @project.bare

        themes = {
          "theme-juice/theme-juice-starter" => "https://github.com/ezekg/theme-juice-starter.git",
          "other"                           => nil,
          "none"                            => nil
        }

        if @project.use_defaults
          theme = themes["theme-juice/theme-juice-starter"]
        else
          choice = @interact.choose "Which starter theme would you like to use?", :blue, themes.keys

          case choice
          when "theme-juice/theme-juice-starter"
            @interact.success "Awesome choice!"
          when "other"
            themes[choice] = @interact.prompt "What is the repository URL for the starter theme that you would like to clone?"
          when "none"
            @interact.notice "Next time you need to create a project without a starter theme, you can just run the 'setup' command instead."
            @project.bare = true
          end

          theme = themes[choice]
        end

        theme
      end

      def vm_location
        File.expand_path "#{@env.vvv_path}/www/#{@env.vm_prefix}-#{@project.name}"
      end
    end
  end
end
