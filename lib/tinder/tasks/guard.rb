module Tinder
    module Tasks
        class Guard < ::Thor
            namespace :watch

            include ::Thor::Actions

            def self.banner(task, namespace = true, subcommand = false)
                "#{basename} #{task.formatted_usage(self, true, subcommand)}"
            end

            ###
            # Watch all
            #
            # This will watch and compile all files
            ###
            desc "all", "Run all Guard plugins"
            def all
                ::Tinder::warning "Initiating Guard..."
                if run "bundle exec guard"
                    # ::Tinder::success "Guard initiated. Watching files..."
                else
                    ::Tinder::error "Failed to initiate Guard. Be sure to run this command from your project root."
                end
            end

            ###
            # Watch Sass files
            #
            # This will watch and compile Sass files with Compass
            ###
            desc "sass", "Watch Sass files with Guard"
            def sass
                ::Tinder::warning "Initiating Guard..."
                if run "bundle exec guard -P compass"
                    # ::Tinder::success "Guard initiated. Watching Sass files..."
                else
                    ::Tinder::error "Failed to initiate Guard. Be sure to run this command from your project root."
                end
            end

            ###
            # Watch Coffee
            #
            # This will watch and compile Coffee files
            ###
            desc "coffee", "Watch Coffee files with Guard"
            def coffee
                ::Tinder::warning "Initiating Guard..."
                if run "bundle exec guard -P coffeescript"
                    # ::Tinder::success "Guard initiated. Watching Coffee files..."
                else
                    ::Tinder::error "Failed to initiate Guard. Be sure to run this command from your project root."
                end
            end

            ###
            # Watch Haml
            #
            # This will watch and compile Haml files
            ###
            desc "haml", "Watch Haml files with Guard"
            def haml
                ::Tinder::warning "Initiating Guard..."
                if run "bundle exec guard -P haml"
                    # ::Tinder::success "Guard initiated. Watching Haml files..."
                else
                    ::Tinder::error "Failed to initiate Guard. Be sure to run this command from your project root."
                end
            end

            ###
            # Optimize images
            #
            # This will optimize all of your images with image_optim
            ###
            desc "image_optim", "Optimize images with Guard"
            def image_optim
                ::Tinder::warning "Initiating Guard..."
                if run "bundle exec guard -P image_optim"
                    # ::Tinder::success "Guard initiated. Optimizing images..."
                else
                    ::Tinder::error "Failed to initiate Guard. Be sure to run this command from your project root."
                end
            end
        end
    end
end
