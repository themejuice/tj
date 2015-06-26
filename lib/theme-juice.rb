# encoding: UTF-8

require "thor"
require "faker"
require "os"
require "yaml"
require "capistrano/all"

module ThemeJuice
end

require "theme-juice/version"
require "theme-juice/helpers/singleton_helper"
require "theme-juice/helpers/hash_helper"
require "theme-juice/env"
require "theme-juice/project"
require "theme-juice/util"
require "theme-juice/io"
require "theme-juice/config"
require "theme-juice/task"
require "theme-juice/tasks/entry"
require "theme-juice/tasks/vm_box"
require "theme-juice/tasks/create_confirm"
require "theme-juice/tasks/delete_confirm"
require "theme-juice/tasks/location"
require "theme-juice/tasks/theme"
require "theme-juice/tasks/repo"
require "theme-juice/tasks/dot_env"
require "theme-juice/tasks/forward_ports"
require "theme-juice/tasks/nginx"
require "theme-juice/tasks/apache"
require "theme-juice/tasks/vm_plugins"
require "theme-juice/tasks/vm_location"
require "theme-juice/tasks/vm_customfile"
require "theme-juice/tasks/database"
require "theme-juice/tasks/landrush"
require "theme-juice/tasks/synced_folder"
require "theme-juice/tasks/dns"
require "theme-juice/tasks/wp_cli"
require "theme-juice/tasks/create_success"
require "theme-juice/tasks/delete_success"
require "theme-juice/tasks/vm_provision"
require "theme-juice/tasks/vm_restart"
require "theme-juice/tasks/import_database"
require "theme-juice/tasks/list"
require "theme-juice/tasks/deploy/stage"
require "theme-juice/tasks/deploy/vm_stage"
require "theme-juice/tasks/deploy/rsync"
require "theme-juice/tasks/deploy/repo"
require "theme-juice/command"
require "theme-juice/commands/create"
require "theme-juice/commands/delete"
require "theme-juice/commands/deploy"
require "theme-juice/cli"
