# Theme Juice
[![Gem Version](http://img.shields.io/gem/v/theme-juice.svg)](https://rubygems.org/gems/theme-juice)
[![Travis](https://img.shields.io/travis/ezekg/theme-juice-cli.svg?style=flat-square)]()
[![Code Climate](https://img.shields.io/codeclimate/github/ezekg/theme-juice-cli.svg?style=flat-square)]()
[![Code Climate](https://img.shields.io/codeclimate/coverage/github/ezekg/theme-juice-cli.svg?style=flat-square)]()
[![GitHub license](https://img.shields.io/github/license/ezekg/theme-juice-cli.svg?style=flat-square)](https://github.com/ezekg/theme-juice-cli/blob/master/LICENSE)

_This project is currently under active development and will not be completely 'stable' per-say until we hit `1.0`. Everything here is subject to change without notice. (We will of course semantically version all of our releases, with the minor version being incremented with new features.) Feel free to contribute to the development with new features, ideas or bug fixes. [View our contributing guidelines](#contributing)_

## What is it?
**Theme Juice** is a WordPress development command line utility that allows you to scaffold out entire Vagrant development environments in seconds (using an Apache fork of [VVV](https://github.com/Varying-Vagrant-Vagrants/VVV) called [VVV-Apache](https://github.com/ericmann/vvv-apache.git) as the VM). It also allows you to manage dependencies and build tools the right way, and even handle deployments.

## Installation
* First, install [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/) for local development.
* Then install with: `gem install theme-juice`
* That's it!

## Windows users
Since Windows doesn't support UTF-8 characters inside of the terminal, and is picky about colors, you'll have to run `tj` with a couple flags. What has worked for me on my Windows machine at home is to run all commands through [git-scm](http://git-scm.com/downloads) with the `--boring --no-landrush` flags.

This disables all unicode characters and colors from being output, and disables [Landrush](https://github.com/phinze/landrush), which isn't fully supported on Windows. To set these globally via the `ENV`, run:

```bash
export TJ_BORING=true
export TJ_NO_LANDRUSH=true
```

In addition to that, `tj` uses the [OS gem](https://github.com/rdp/os) to sniff out your OS and adjusts a few things accordingly to make sure things don't break. _I don't regularly develop on Windows, so if you encounter any bugs, please let me know through a **well-documented** issue and I'll try my best to get it resolved._

## Config
Because everybody likes to use different tools, you can create a `Juicefile` or `tj.yaml` config (with an optional preceding `.`) that will house all of your theme-specific commands. This allows you to use a streamlined set of commands that will act as aliases to your per-project configuration, as well as starter-theme specific information, such as deployment configuration, etc. For right now, we'll just stick to the `commands` section.

If you're into [Grunt](https://github.com/gruntjs/grunt), then use it. Prefer [Gulp](https://github.com/gulpjs/gulp)? What about [Guard](https://github.com/guard/guard)? Go right ahead. It's compeletely up to you and your team. This is obviously relative to the starter theme you use, since you can't exactly use Grunt with a project that doesn't support it.

Below is the config that comes baked into [our starter theme](https://github.com/ezekg/theme-juice-starter):

```yml
commands:
  install:
    - composer install
    - npm install
    - bower install
    - grunt build
  watch:
    - grunt %args%
  vendor:
    - composer %args%
  wp:
    - wp ssh --host=vagrant %args%
  backup:
    - mkdir -p backup
    - wp ssh --host=vagrant db export backup/$(date +'%Y-%m-%d-%H-%M-%S').sql
  dist:
    - tar -zcvf dist.tar.gz .
```

Each list of commands is run within a single execution, with all `%args%`/`%argN%` being replaced by the passed command. Here's a few example scenarios:
```bash
# Will contain all arguments stitched together by a space
cmd1 %args%
# Will contain each argument mapped to its respective index
cmd2 '%arg1% %arg2% %arg3%'
# Will only map argument 4, while ignoring 1-3
cmd3 "%arg4%"
```

You can specify an unlimited number of commands with an unlimited number of arguments; however, should be careful with how this is used. Don't do something like including `sudo rm -rf %arg1%` in a command, and then passing `/` as an argument. Keep it simple. These are meant to make your life easier by managing build tools, not to do fancy scripting.

## Usage

Use the `man` page to print command usage:

```
tj
tj -h
tj help
tj --help
```

See [themejuice.it](http://themejuice.it) for the full documentation.

## Can I add my starter theme, ________?
Yes! Just update the `THEMES` constant inside [commands/create.rb](https://github.com/ezekg/theme-juice-cli/blob/master/lib/theme-juice/commands/create.rb#L7-L11) and make a pull request. I'll verify that the theme includes a `Juicefile` (not required, but preferred to automate build steps), and that everything looks solid. Until then (or if your theme is private), just run `tj create --theme https://your.repo/link/goes.here` to clone your theme.

## Contributing
1. First, create a _well documented_ [issue](https://github.com/ezekg/theme-juice-cli/issues) for your proposed feature/bug fix.
1. [Fork the repository](https://github.com/ezekg/theme-juice-cli/fork).
1. Create a new feature branch. (`git checkout -b my-new-feature`)
1. Commit your changes. (`git commit -am 'add some feature'`)
1. Push to the new branch. (`git push origin my-new-feature`)
1. Create a new Pull Request.
