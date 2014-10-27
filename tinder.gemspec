require_relative 'lib/tinder'

Gem::Specification.new do |spec|

    # Info
    spec.version = Tinder::VERSION

    # Details
    spec.name = "tinder-cli"
    spec.rubyforge_project = "tinder-cli"
    spec.licenses = "MIT"
    spec.authors = ["Ezekiel Gabrielse"]
    spec.email = ["ezekg@yahoo.com"]
    spec.homepage = "https://github.com/ezekg/tinder-cli.git"

    # Description
    spec.summary = %q{A WordPress theme development framework.}
    spec.description = %q{A WordPress theme development framework.}

    # Library
    spec.files += Dir.glob("lib/**/*.*")

    # Other
    spec.files += ["LICENSE", "README.md"]

    # Executable
    spec.executables = ["tinder"]

    # Test
    # spec.test_files += Dir.glob("tests/**/*.*")

    # Dependencies
    spec.add_dependency "thor"
    spec.add_dependency "colorize"
end
