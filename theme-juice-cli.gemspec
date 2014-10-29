require_relative 'lib/theme-juice'

Gem::Specification.new do |spec|

    # Info
    spec.version = ThemeJuice::VERSION

    # Details
    spec.name = "theme-juice-cli"
    spec.rubyforge_project = "theme-juice-cli"
    spec.licenses = "MIT"
    spec.authors = ["Ezekiel Gabrielse"]
    spec.email = ["ezekg@yahoo.com"]
    spec.homepage = "https://github.com/ezekg/theme-juice-cli.git"

    # Description
    spec.summary = %q{A WordPress theme development framework.}
    spec.description = %q{A WordPress theme development framework that scaffolds out an entire Vagrant development environment in seconds.}

    # Library
    spec.files += Dir.glob("lib/**/*.*")

    # Other
    spec.files += ["LICENSE", "README.md"]

    # Executable
    spec.executables = ["tj"]

    # Test
    # spec.test_files += Dir.glob("tests/**/*.*")

    # Dependencies
    spec.add_dependency "thor"
    spec.add_dependency "artii"
    spec.add_dependency "colorize"
end
