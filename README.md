# Theme Juice [![Gem Version](http://img.shields.io/gem/v/theme-juice.svg)](https://rubygems.org/gems/theme-juice)
What is it? Theme Juice is a WordPress development command line utility that allows you to scaffold out entire Vagrant development environments in seconds (using [VVV](https://github.com/Varying-Vagrant-Vagrants/VVV) as the VM), manage dependencies and build tools, and even handle deployments.

## Installation
* First, install [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/) for local development.
* Then, install [Composer](https://getcomposer.org/) and [WP-CLI](http://wp-cli.org/), and make sure they're executable.
* Finally, install with: `gem install theme-juice`
That`s it!

## Windows users
Since Windows doesn't support UTF-8 characters inside of the terminal, and is picky about colors, you'll have to run `tj` with a couple flags. What has worked for me on my Windows machine at home is to run all commands through [git-scm](http://git-scm.com/downloads) with the `--boring --no-landrush` flags. This disables all unicode characters and colors from being output, and disables [Landrush](https://github.com/phinze/landrush) which isn't supported fully on Windows.  To set these globally via the `ENV`, run:

```bash
export TJ_BORING=true
export TJ_NO_LANDRUSH=true
```

In addition to that, `tj` uses the [OS gem](https://github.com/rdp/os) to sniff out your OS and adjusts a few things accordingly. Windows users won't see any fancy select menus or anything like that to avoid crashing (since Windows doesn't support `stty`, which is what is used).

_If you encounter any bugs, please let me know through a **well-documented** issue and I'll try my best to get it resolved._

## Config
Because everybody likes to use different tools, you can create a `Juicefile` or `tj.yaml` config (with an optional preceding `.`) that will house all of your theme-specific commands. This allows you to use a streamlined set of commands that will act as aliases to your per-project configuration, as well as starter-theme specific information, such as deployment configuration, etc. For right now, we'll just stick to the `commands` section.

If you're into [Grunt](https://github.com/gruntjs/grunt), then use it. Prefer [Guard](https://github.com/guard/guard)? Go right ahead. This is obviously relative to the starter theme you use, since you can't exactly use Grunt with a project that doesn't support it. Below is the config that comes baked into [our starter theme](https://github.com/ezekg/theme-juice-starter):

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

Each command is run within a single execution, with all arguments passed to each command; i.e. `cmd1 [<ARGS>] && cmd2 [<ARGS>] && ...`. So, you should be careful with how this is used. Don't do something like including `sudo rm -rf` in a command, and then passing `/` as an argument. Keep it simple.

## Usage

### List available commands:
List all commands for `tj`.
```bash
tj
```

### Print version:
This command will print the current version of `tj`.
```bash
tj --version # Aliases: -v version
```

### Global flags:
| Flag                   | Type   | Description                                |
|:---------------------- |:------ |:------------------------------------------ |
| `[--vm-path=PATH]`     | Path   | Force path to VM                           |
| `[--vm-ip=IP]`         | String | Force IP address for VM                    |
| `[--vm-prefix=PREFIX]` | String | Force directory prefix for project in VM   |
| `[--yolo]`             | Bool   | Say yes to anything and everything         |
| `[--boring]`           | Bool   | Disable all the coolness                   |
| `[--no-unicode]`       | Bool   | Disable all unicode characters             |
| `[--no-colors]`        | Bool   | Disable all colored output                 |
| `[--no-animations]`    | Bool   | Disable all animations                     |
| `[--no-landrush]`      | Bool   | Disable landrush for DNS                   |
| `[--verbose]`          | Bool   | Verbose output                             |
| `[--dryrun]`           | Bool   | Disable running all commands               |

_Use `ENV` variables to set global flags. For example, by running `export TJ_VM_PATH=~/vagrant-vvv`, the `ENV` variable will be used instead of the default `vm-path` from then on. You can remove global flags with `unset TJ_VM_PATH`_

### Creating a new development site:
Use this to create a new project. It will automagically set up your VM, including a local development site at `http://<url>.dev` with WordPress installed and a fresh WP database. It will sync up your local site installation with the Vagrant VM, so you can organize your projects however you want. This task will also install VVV into your `vm-path` directory if it has not already been installed.
```bash
tj create # Aliases: mk make new add
```

#### Option flags:
| Flag                                | Type   | Description                                      |
|:----------------------------------- |:------ |:------------------------------------------------ |
| `[-n, --name=NAME]`                 | String | Name of the project                              |
| `[-l, --location=LOCATION]`         | Path   | Location of the local project                    |
| `[-t, --theme=THEME]`               | URL    | Starter theme to install                         |
| `[-u, --url=URL]`                   | URL    | Development URL for the project                  |
| `[-r, --repository=REPO]`           | URL    | Initialize a new Git remote repository           |
| `[-i, --import-db=DB]`              | Path   | Import an existing database                      |
| `[--bare]`                          | Bool   | Create a project without a starter theme         |
| `[--skip-repo]`                     | Bool   | Skip repository prompts and use default settings |
| `[--skip-db]`                       | Bool   | Skip database prompts and use default settings   |
| `[--use-defaults]`                  | Bool   | Skip all prompts and use default settings        |
| `[--no-wp]`                         | Bool   | New project is not a WordPress install           |
| `[--no-db]`                         | Bool   | New project does not need a database             |

### Setting up an existing site:
Use this to setup an existing local site installation within the development environment. You will go through the setup process to create the necessary files for the VM, including `vvv-hosts`, `vvv-nginx.conf`, and a fresh database (unless one already exists by the name chosen). This is essentially an alias for `create`, but with a few options being skipped.
```bash
tj setup # Aliases: up prep init
```

#### Option flags:
| Flag                                | Type   | Description                                      |
|:----------------------------------- |:------ |:------------------------------------------------ |
| `[-n, --name=NAME]`                 | String | Name of the project                              |
| `[-l, --location=LOCATION]`         | Path   | Location of the local project                    |
| `[-u, --url=URL]`                   | URL    | Development URL for the project                  |
| `[-r, --repository=REPO]`           | URL    | Initialize a new Git remote repository           |
| `[-i, --import-db=DB]`              | Path   | Import an existing database                      |
| `[--skip-repo]`                     | Bool   | Skip repository prompts and use default settings |
| `[--skip-db]`                       | Bool   | Skip database prompts and use default settings   |
| `[--use-defaults]`                  | Bool   | Skip all prompts and use default settings        |
| `[--no-wp]`                         | Bool   | New project is not a WordPress install           |
| `[--no-db]`                         | Bool   | New project does not need a database             |

### Deleting a site from the VM: _(Does not remove your local site)_
Use this to remove a site from your development environment. This will only remove files that were generated by `tj`. including the database setup, development url, and shared directories. _It will not touch your local folders that were synced to the VM._
```bash
tj delete # Aliases: rm remove trash teardown
```

#### Option flags:
| Flag                | Type   | Description                     |
|:------------------- |:------ |:------------------------------- |
| `[-n, --name=NAME]` | String | Name of the development project |
| `[-u, --url=URL]`   | URL    | Development URL for the project |
| `[--db-drop]`       | Bool   | Drop project's database         |
| `[--vm-restart]`    | Bool   | Restart VM after deletion       |

### Managing deployment and migration (coming soon):
Use this to easily manage your deployment and migration with [Capistrano](https://github.com/capistrano/capistrano) or whatever command is in your config. This is just a wrapper for your chosen command.
```bash
tj deploy # Aliases: deployer server remote
```

### Listing all `tj` projects in the VM:
Use this to list all projects within your VM that were generated by `tj`.
```bash
tj list # Aliases: ls projects apps sites
```

### Managing development environment:
Use this to easily manage your [Varying Vagrant Vagrants](https://github.com/Varying-Vagrant-Vagrants/VVV) VM. This is a wrapper for Vagrant commands executed within your VM path.
```bash
tj vm # Aliases: vagrant vvv
```

### Watching and compiling assets:
Use this to watch and compile assets with your preferred build tool, whether that be [Grunt](https://github.com/gruntjs/grunt), [Gulp](https://github.com/gulpjs/gulp), [Guard](https://github.com/guard/guard), or whatever. This is simply a wrapper for whatever command is in your config file.
```bash
tj watch # Aliases: assets dev build
```

### Managing vendor dependencies:
Use this to easily manage your dependencies with [Composer](https://github.com/composer/composer), or whatever command you set within your config.
```bash
tj vendor # Aliases: dependencies deps
```

### Executing WP-CLI locally inside your VM:
Upon setup, an `ssh` block for the VM is automatically added to the `wp-cli.local.yml` file with all of your VM paths. In our starter theme, we use [wp-cli-ssh](https://github.com/xwp/wp-cli-ssh) to run `wp` commands locally.
In order to do the same, it needs to be a dependency in your `composer.json`.
```bash
tj wp # Aliases: wordpress
```

### Backing up your database:
Uses `backup` command within your config.
```bash
tj backup # Aliases: bk
```

### Distributing a package of your project:
Uses `dist` command within your config.
```bash
tj dist # Aliases: distrubute pack package
```

### Running your test suite:
Uses `dist` command within your config.
```bash
tj test # Aliases: tests spec specs
```

## Contributing

1. First, create an [issue](https://github.com/ezekg/theme-juice-cli/issues) for your proposed feature. If it's a bug fix, go right to step 2.
1. [Fork the repository](https://github.com/ezekg/theme-juice-cli/fork).
1. Create a new feature branch. (`git checkout -b my-new-feature`)
1. Commit your changes. (`git commit -am 'add some feature'`)
1. Push to the new branch. (`git push origin my-new-feature`)
1. Create a new Pull Request.
