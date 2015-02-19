# encoding: UTF-8

module ThemeJuice
    module Environment
        class << self
            attr_accessor :vvv_path
            attr_accessor :no_unicode
            attr_accessor :no_colors
            # attr_accessor :no_animations
            # attr_accessor :no_deployer
            attr_accessor :boring
            attr_accessor :yolo
        end
    end
end
