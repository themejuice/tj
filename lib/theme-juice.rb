# encoding: UTF-8

require "thor"
require "faker"
require "fileutils"
require "pathname"
require "tempfile"
require "shellwords"
require "yaml"

module ThemeJuice
end

require_relative "theme-juice/version"
require_relative "theme-juice/env"
require_relative "theme-juice/project"
require_relative "theme-juice/util"

require_relative "theme-juice/interact"
require_relative "theme-juice/interactions/teejay"
require_relative "theme-juice/interactions/create"
require_relative "theme-juice/interactions/delete"

require_relative "theme-juice/config"

require_relative "theme-juice/task"
require_relative "theme-juice/tasks/vm"
require_relative "theme-juice/tasks/location"
require_relative "theme-juice/tasks/theme"

require_relative "theme-juice/service"
require_relative "theme-juice/services/configuration"
require_relative "theme-juice/services/create"
require_relative "theme-juice/services/delete"
require_relative "theme-juice/services/list"

require_relative "theme-juice/command"
require_relative "theme-juice/commands/install"
require_relative "theme-juice/commands/create"
require_relative "theme-juice/commands/delete"
require_relative "theme-juice/commands/list"
require_relative "theme-juice/commands/deployer"
require_relative "theme-juice/commands/subcommand"

require_relative "theme-juice/cli"
