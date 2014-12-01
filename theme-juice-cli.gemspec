require_relative "lib/theme-juice"

Gem::Specification.new do |spec|

    # Version
    spec.version = ThemeJuice::VERSION

    # Details
    spec.name = "theme-juice-cli"
    spec.rubyforge_project = "theme-juice-cli"
    spec.licenses = "MIT"
    spec.authors = ["Ezekiel Gabrielse"]
    spec.email = ["ezekg@yahoo.com"]
    spec.homepage = "https://github.com/ezekg/theme-juice-cli.git"

    # Description
    spec.summary = %q{A WordPress development framework.}
    spec.description = %q{A WordPress development framework that scaffolds out an entire Vagrant development environment in seconds. Uses trendy tech like Haml, Sass and CoffeeScript.}

    # Library
    spec.files += Dir.glob("lib/**/*.*")

    # Other
    spec.files += ["LICENSE", "README.md"]

    # Executable
    spec.executables = ["tj"]

    # Test
    # spec.test_files += Dir.glob("tests/**/*.*")

    # Required Ruby version
    spec.required_ruby_version = ">= 2.0.0"

    # Dependencies
    spec.add_dependency "thor"
    spec.add_dependency "artii"
    spec.add_dependency "colorize"
end
