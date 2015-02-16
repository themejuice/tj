# Theme Juice [![Gem Version](http://img.shields.io/gem/v/theme-juice.svg)](https://rubygems.org/gems/theme-juice)
What is it? Theme Juice is a command line interface created to scaffold out a new WordPress development environment (using [VVV](https://github.com/Varying-Vagrant-Vagrants/VVV)) and countless development sites. Everybody loves one command setups, and `tj` can even do one command deployments too.

## Installation
* First, install [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/) for local development.
* Then, install [Composer](https://getcomposer.org/) and [WP-CLI](http://wp-cli.org/) (make sure they're executable).
* Finally, install with: `gem install theme-juice`
That`s it!

## Config
Because everybody likes to use different tools, you can create a `tj.yml` file (with an optional preceding `.`) that will house all of your theme-specific commands. This allows you to use a streamlined set of commands that will act as aliases to your per-project configuration, as well as starter-theme specific information, such as deployment configuration, etc. For right now, we'll just stick to the `commands` section.

If you're into [Grunt](https://github.com/gruntjs/grunt), then use it. Prefer [Guard](https://github.com/guard/guard)? Go right ahead. This is obviously relative to the starter theme you use, since you can't exactly use Grunt with a starter theme that doesn't support it. Below is the config that comes baked into [our starter theme](https://github.com/ezekg/theme-juice-starter):

```yml
commands:
    watch: bundle exec guard
    server: bundle exec cap
    vendor: composer
    install:
        - composer install
```

_Note: If you use a starter theme that doesn't have a `tj.yml` file, you'll be prompted through a series of steps in order to create one._

### Command options:
| Option    | Usage                                                                         |
|:--------- |:----------------------------------------------------------------------------- |
| `watch`   | Command to be aliased when you run `tj watch` for bulding assets              |
| `server`  | Command to be aliased when you run `tj server` for deployments                |
| `vendor`  | Command to be aliased when you run `tj vendor` for dependencies               |
| `install` | Each command is executed when you run `tj install` to prepare a starter theme |

## Usage

### List available commands:
List all commands for `tj`.
```bash
tj
```

#### Global flags:
| Flag                     | Type   | Description                                |
|:-------------------------|:------ |:------------------------------------------ |
| `-nu, [--no-unicode]`    | Bool   | Disable all unicode characters             |
| `-nc, [--no-colors]`     | Bool   | Disable colored output                     |
| `-fp, [--vvv-path=PATH]` | String | Force custom path to your VVV installation |

### Print version:
This command will print the current version of `tj`.
```bash
tj --version # Aliases: -v, version
```

### Creating a new development site:
Use this to create a new development site. It will automagically set up your entire development environment, including a local development site at `http://<sites-dev-url>.dev` with WordPress installed and a fresh WP database. It will sync up your local site installation with the Vagrant VM. This task will also install and configure Vagrant/VVV into your `~/` directory if it has not already been installed. Site name is optional, as it will be asked for if not given.
```bash
tj create [<SITE-NAME>] # Aliases: new, add, build, make
```

#### Option flags:
| Flag                        | Type   | Description                                      |
|:--------------------------- |:------ |:------------------------------------------------ |
| `-b, [--bare]`              | Bool   | Create a VVV site without a starter theme        |
| `-s, [--site=SITE]`         | String | Name of the development site                     |
| `-l, [--location=LOCATION]` | Path   | Location of the local site                       |
| `-t, [--theme=THEME]`       | URL    | Starter theme to install                         |
| `-u, [--url=URL]`           | URL    | Development URL of the site (must end in `.dev`) |
| `-r, [--repository]`        | String | Initialize a new Git remote repository           |
| `[--skip-repo]`             | Bool   | Skip repository prompts and set to `none`        |
| `[--skip-db]`               | Bool   | Skip database prompts and use defaults           |
| `[--use-defaults]`          | Bool   | Skip all prompts and use defaults                |

### Setting up an existing site:
Use this to setup an existing local site installation within the development environment. You will go through the setup process to create the necessary files for the VM, including `vvv-hosts`, `vvv-nginx.conf`, and a fresh database (unless one already exists by the name chosen). Site name is optional, as it will be asked for if not given.
```bash
tj setup [<SITE-NAME>] # Aliases: init, prep
```

### Deleting a site from the VM: _(Does not remove your local site)_
Use this to remove a site from your development environment. This is only remove files that were generated by `tj`. including the database setup, development url, and shared directories. _It will not touch your local files._
```bash
tj delete <SITE-NAME> # Aliases: remove, trash, teardown
```

### Listing all `tj` sites in the VM:
Use this to list all sites within your development environment that were generated by `tj`.
```bash
tj list # Aliases: sites, show
```

### Watching and compiling assets:
Use this to watch and compile assets with your preferred build tool, whether that be [Grunt](https://github.com/gruntjs/grunt), [Gulp](https://github.com/gulpjs/gulp), [Guard](https://github.com/guard/guard), or whatever. This is simply a wrapper for whatever command is in your `tj.yml` file.
```bash
tj watch # Aliases: dev, assets
```

### Managing development environment:
Use this to easily manage your [Varying Vagrant Vagrants](https://github.com/Varying-Vagrant-Vagrants/VVV) development environment. This is simply a wrapper for Vagrant commands executed within your VVV path.
```bash
tj vm # Aliases: vagrant, vvv
```

### Managing vendor dependencies:
Use this to easily manage your dependencies with [Composer](https://github.com/composer/composer), or whatever other command you set in your `tj.yml`. This is a wrapper for whatever command is in your config file.
```bash
tj vendor # Aliases: deps, dependencies
```

### Managing deployment and migration:
Use this to easily manage your deployment and migration with [Capistrano](https://github.com/capistrano/capistrano) (or again, anything else set within your `tj.yml`). This is just a wrapper for your chosen command.
```bash
tj server # Aliases: deploy, remote
```

### Executing WP-CLI locally inside your VM with `wp-cli-ssh`
You can run `wp` commands locally if you specify a `--host`. Upon setup, an `ssh` block for the VM is automatically added to the `wp-cli.local.yml` file with all of your development environment paths.
```bash
wp ssh --host=vagrant [<COMMANDS>]

# Create an alias
alias wpv="wp ssh --host=vagrant"
```

## Contributing

1. First, create an [issue](https://github.com/ezekg/theme-juice-cli/issues) for your proposed feature. If it's a bug fix, go right to step 2.
1. [Fork the repository](https://github.com/ezekg/theme-juice-cli/fork).
1. Create a new feature branch. (`git checkout -b my-new-feature`)
1. Commit your changes. (`git commit -am 'add some feature'`)
1. Push to the new branch. (`git push origin my-new-feature`)
1. Create a new Pull Request.
