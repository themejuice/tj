# Theme Juice [![Gem Version](http://img.shields.io/gem/v/theme-juice.svg)](https://rubygems.org/gems/theme-juice)
What is it? Theme Juice is a command line interface created to scaffold out a new WordPress development environment (using [VVV](https://github.com/Varying-Vagrant-Vagrants/VVV)) and countless development sites. Everybody loves one command setups, and `tj` can even do one command deployments too.

## Installation
* First, install [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/) for local development.
* Then, install [Composer](https://getcomposer.org/) and [WP-CLI](http://wp-cli.org/) (make sure they're executable).
* Finally, install with: `gem install theme-juice`
That`s it!

## Config
Because everybody likes to use different tools, you can create a `Juicefile` or `tj.yaml` config (with an optional preceding `.`) that will house all of your theme-specific commands. This allows you to use a streamlined set of commands that will act as aliases to your per-project configuration, as well as starter-theme specific information, such as deployment configuration, etc. For right now, we'll just stick to the `commands` section.

If you're into [Grunt](https://github.com/gruntjs/grunt), then use it. Prefer [Guard](https://github.com/guard/guard)? Go right ahead. This is obviously relative to the starter theme you use, since you can't exactly use Grunt with a starter theme that doesn't support it. Below is the config that comes baked into [our starter theme](https://github.com/ezekg/theme-juice-starter):

```yml
commands:
  install:
    - composer install
  watch:
    - grunt
  vendor:
    - composer
  wp:
    - wp ssh --host=vagrant
  backup:
    - wp ssh --host=vagrant db export backup/$(date +'%Y-%m-%d-%H-%M-%S').sql
  dist:
    - tar -zcvf dist.tar.gz .

```

## Usage

### List available commands:
List all commands for `tj`.
```bash
tj
```

### Print version:
This command will print the current version of `tj`.
```bash
tj --version # Aliases: -v, version
```

### Global flags:
| Flag                   | Type   | Description                                |
|:---------------------- |:------ |:------------------------------------------ |
| `[--vm_path=PATH]`     | String | Force path to VM                           |
| `[--vm_ip=IP]`         | String | Force IP address for VM                    |
| `[--vm_prefix=PREFIX]` | String | Force directory prefix for project in VM   |
| `[--yolo]`             | Bool   | Say yes to anything and everything         |
| `[--boring]`           | Bool   | Disable all the coolness                   |
| `[--no_unicode]`       | Bool   | Disable all unicode characters             |
| `[--no_colors]`        | Bool   | Disable all colored output                 |
| `[--no_animations]`    | Bool   | Disable all animations                     |
| `[--no_landrush]`      | Bool   | Disable landrush for DNS                   |
| `[--verbose]`          | Bool   | Verbose output                             |
| `[--dryrun]`           | Bool   | Disable running all commands               |

_Use `ENV` variables to set global flags. For example, by running `export TJ_VM_PATH=~/vagrant-vvv`, the `ENV` variable will be used instead of the default `vm-path` from then on. You can remove global flags with `unset TJ_VM_PATH`_

### Creating a new development site:
Use this to create a new development site. It will automagically set up your entire development environment, including a local development site at `http://<sites-dev-url>.dev` with WordPress installed and a fresh WP database. It will sync up your local site installation with the Vagrant VM. This task will also install and configure Vagrant/VVV into your `vm-path` directory if it has not already been installed. Site name is optional, as it will be asked for if not given.
```bash
tj create # Aliases: mk new add
```

#### Option flags:
| Flag                        | Type   | Description                                      |
|:--------------------------- |:------ |:------------------------------------------------ |
| `-b, [--bare]`              | Bool   | Create a VVV site without a starter theme        |
| `-n, [--name=NAME]`         | String | Name of the development site                     |
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
tj setup # Aliases: up prep init make
```

#### Option flags:
| Flag                        | Type   | Description                                      |
|:--------------------------- |:------ |:------------------------------------------------ |
| `-n, [--name=NAME]`         | String | Name of the development site                     |
| `-l, [--location=LOCATION]` | Path   | Location of the local site                       |
| `-u, [--url=URL]`           | URL    | Development URL of the site (must end in `.dev`) |
| `-r, [--repository]`        | String | Initialize a new Git remote repository           |
| `[--skip-repo]`             | Bool   | Skip repository prompts and set to `none`        |
| `[--skip-db]`               | Bool   | Skip database prompts and use defaults           |
| `[--use-defaults]`          | Bool   | Skip all prompts and use defaults                |

### Deleting a site from the VM: _(Does not remove your local site)_
Use this to remove a site from your development environment. This is only remove files that were generated by `tj`. including the database setup, development url, and shared directories. _It will not touch your local files._
```bash
tj delete # Aliases: rm remove trash teardown
```

#### Option flags:
| Flag                    | Type   | Description                                      |
|:----------------------- |:------ |:------------------------------------------------ |
| `-n, [--name=NAME]`     | String | Name of the development site                     |
| `[--restart]`           | Bool   | Restart development environment after deletion   |

### Listing all `tj` sites in the VM:
Use this to list all sites within your development environment that were generated by `tj`.
```bash
tj list # Aliases: ls projects apps sites
```

### Watching and compiling assets:
Use this to watch and compile assets with your preferred build tool, whether that be [Grunt](https://github.com/gruntjs/grunt), [Gulp](https://github.com/gulpjs/gulp), [Guard](https://github.com/guard/guard), or whatever. This is simply a wrapper for whatever command is in your `tj.yml` file.
```bash
tj watch # Aliases: assets dev build
```

### Managing development environment:
Use this to easily manage your [Varying Vagrant Vagrants](https://github.com/Varying-Vagrant-Vagrants/VVV) development environment. This is simply a wrapper for Vagrant commands executed within your VVV path.
```bash
tj vm # Aliases: vagrant vvv
```

### Managing vendor dependencies:
Use this to easily manage your dependencies with [Composer](https://github.com/composer/composer), or whatever other command you set in your `tj.yml`. This is a wrapper for whatever command is in your config file.
```bash
tj vendor # Aliases: dependencies deps
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
