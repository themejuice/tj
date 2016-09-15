# `tj`
[![Mac App](https://img.shields.io/badge/mac-app-brightgreen.svg)](https://www.themejuice.it)
[![Gem Version](http://img.shields.io/gem/v/theme-juice.svg?style=flat-square)](https://rubygems.org/gems/theme-juice)
[![Travis](https://img.shields.io/travis/themejuice/tj.svg?style=flat-square)](https://travis-ci.org/themejuice/tj)
[![Code Climate](https://img.shields.io/codeclimate/github/themejuice/tj.svg?style=flat-square)](https://codeclimate.com/github/themejuice/tj)
[![Code Climate](https://img.shields.io/codeclimate/coverage/github/themejuice/tj.svg?style=flat-square)](https://codeclimate.com/github/themejuice/tj)

![Theme Juice CLI](demo.gif)

## What is it?
The [Theme Juice CLI](http://cli.themejuice.it), also known as `tj`, helps you create new local WordPress development sites, manage existing sites, and deploy them, all from the command line. It utilizes our [Graft VM](https://github.com/themejuice/graft) for the virtual machine to spin up new development sites in seconds.

Check out [our getting started guide over at SitePoint](http://www.sitepoint.com/introducing-theme-juice-for-local-wordpress-development/), or [view the documentation site](http://cli.themejuice.it).

## What problems does `tj` help solve?
To get the most out of `tj`, it is recommended that you use our [starter template](https://github.com/themejuice/sprout). Why? Keep on reading and we'll tell you. `tj` is built on top of tried and true open source libraries such as [Capistrano](http://capistranorb.com/) for deployment, [Vagrant](https://www.vagrantup.com/) for local development, and even a little bit of [WP-CLI](http://wp-cli.org) for database migration. Some of the main pain points `tj` helps solve are:

### 1. Local development
Say goodbye to MAMP! With one command, `tj create`, you can have a new local development site up and running in under a minute. It uses Vagrant to create a robust development environment, and lets you create and manage multiple projects within a single virtual machine. It also handles deployments over SSH using Capistrano if you want to move away from FTP (more about that below).

### 2. Multi-environment projects
Oh, multi-environment development! Usually, you would have to ignore your entire `wp-config.php` file and create one for every single stage. These can get out of sync fast. Even worse, the config file actually gets checked into the project repo and so the credentials fluctuate from `dev` to `staging` to `production`. Not good. Not good at all.

Our [starter template](https://github.com/themejuice/sprout) uses a `.env` file, and has support for an unlimited number of environments (we generally do `development`, `staging` and `production`). Since these settings are housed in a `.env` file, they are not checked into the repo. That means the codebase is 100% environment agnostic. [The way it should be.](http://12factor.net/)

### 3. Multi-environment deployments
Really. Want to deploy to staging? Set up a staging environment inside of the [`Juicefile`](https://github.com/themejuice/sprout/blob/master/Juicefile?ts=2), make sure you can SSH in without a password (remember, best practices here!) and run `tj deploy staging`. Boom, you're done. Make a mistake? Run `tj remote staging rollback`. Crisis averted!

Want to pull the database from your production server to your development install? Run `tj remote production db:pull` and you're good to go; `tj` will automatically handle rewriting any URLs within the database.

How about pushing your development database and your local uploads folder? Run `tj remote production db:push && tj remote production uploads:push` and you're done. [You can even send notifications to your teams Slack channel if you want to!](#can-i-integrate-my-deployments-with-slack)

## Requirements
**`tj` requires [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/) to be able to create virtual machines for local development. Please download and install both of these before getting started.** If you plan on using `tj` for deployments, you should also ensure that your `remote` servers have [WP-CLI](http://wp-cli.org/) installed in order for `tj` to be able to handle database migration.

I recommend one of the latest versions of Ruby MRI (2.2, 2.1, 2.0). `tj` requires at least MRI 1.9.3. For the full report, check out the [Travis CI build status](https://travis-ci.org/themejuice/tj), where I test against an array of Ruby interpreters.

I also recommend you set up [SSH-keys for GitHub](https://help.github.com/articles/generating-ssh-keys/). Internally, `tj` uses `git clone` with SSH URLs, [so things might break if you don't have your keys set up properly](#help-it-wont-let-me-git-clone-anything).

## Installation
```
gem install theme-juice
```

## Getting Started

_If you're going to be using [our starter template](https://github.com/themejuice/sprout), then I recommend checking out [it's dependencies](https://github.com/themejuice/sprout#development-dependencies) before running your first `create`. That way, the build step doesn't fail._

### Initialize the VM
This will install and configure the virtual machine. It will clone the VM into the `vm-path`, install the required Vagrant plugins (such as [Landrush](https://github.com/phinze/landrush), unless disabled) and will also set up port forwarding if you're on OSX.

```
tj init
```

### Create a new project
This will lead you through a series of prompts to set up required project information, such as name, location, template, database info, etc. Using the specified information, it will run the installation process and set up a local development environment, if one hasn't already been set up. It will sync your local project location with the project
location within the VM, so you can run this from anywhere on your local system.

```
tj create
```

#### What happens on your first `create`?
1. `tj` will execute `tj init` if the VM is uninitialized
1. `tj` will clone the selected starter template
1. `tj` will run the starter template's `Juicefile` install command
1. `tj` will create all of the necessary project files, such as:
  * Create/append to `Customfile` containing DNS and synced folder settings
  * Create/append to `init-custom.sql` for database creation and setup
  * Create `$project.conf` containing Apache server settings
  * Create `wp-cli.local.yml` containing SSH settings
1. `tj` will provision the VM to put the new configuration into effect

If you've never used `tj` before, then that last step might take a little while. After that's done, you should be able to access your new project at the specified development url. It's that easy!

### Set up an existing project
This sets up an existing local project within the development environment. You will go through a series of prompts to create the necessary files. This command is essentially an alias for `tj create --bare`.

```
tj setup
```

### Remove a project
This will remove a project from your development environment. You will go through a series of prompts to delete a project. This will only remove files that were generated by `tj` i.e. the database setup, DNS setup, and other project configuration files.

It will not touch your local folders that were synced to the VM.

```
tj delete
```

### Deploy a project
After configuring your `Juicefile` and setting up SSH keys for yourself, this will deploy a project to the passed `<stage>` using [Capistrano](http://capistranorb.com/). Head over to the [docs](http://cli.themejuice.it/deploy) to see all of the available commands. There's a quick getting started section there too for your first deployment!

```
tj deploy <stage>
```

### Want more?
Want to check out all of the various flags and features `tj` offers? Just ask `tj` for help, and you'll be greeted with a nice `man` page full of information about how to use just about everything.

```
tj help
```

Or, you can also check out [cli.themejuice.it](http://cli.themejuice.it) for a pretty website chock-full of the same documentation provided by `tj help`.

## FAQ

1. [Is Windows supported?](#is-windows-supported)
1. [Can I use another VM instead of Graft?](#can-i-use-another-vm-instead-of-graft)
1. [So, does that mean I can use any Vagrant box?](#so-does-that-mean-i-can-use-any-vagrant-box)
1. [What is a `Customfile`?](#what-is-a-customfile)
1. [What is a `Juicefile`?](#what-is-a-juicefile)
1. [Does `tj` support subdomain multi-sites?](#does-tj-support-subdomain-multi-sites)
1. [Can I access a project from another device (i.e. mobile)?](#can-i-access-a-project-from-another-device-ie-mobile)
1. [Can I add my starter template, ________?](#can-i-add-my-starter-template-________)
1. [Can I integrate my deployments with Slack?](#can-i-integrate-my-deployments-with-slack)
1. [Can I use a self-signed SSL cert?](#can-i-use-a-self-signed-ssl-cert)
1. [Can I define my own Capistrano tasks?](#can-i-define-my-own-capistrano-tasks)
1. [Can I run `wp-cli` commands on my deployment stages?](#can-i-run-wp-cli-commands-on-my-deployment-stages)
1. [Troubleshooting](#troubleshooting)

### Is Windows supported?
Yes! But, since Windows doesn't support UTF-8 characters inside of the terminal, and is picky about ANSI color codes, you'll probably have to run `tj` with a couple flags.

Something that has worked for me on one of my Windows machines is to run all commands through [git-scm](http://git-scm.com/downloads) with the `--boring` flags. This will disable all unicode characters and colors from being output. You may also use the `--no-landrush` flag to disable [Landrush](https://github.com/phinze/landrush), which currently has experimental Windows support (at least try it first and help report any bugs!).

To set these globally via the `ENV`, set the following environment variables:

```bash
TJ_BORING=true
TJ_NO_LANDRUSH=true
```

In addition to that, `tj` uses the [OS gem](https://github.com/rdp/os) to sniff out your OS and it'll adjust a few things accordingly to make sure that nothing breaks.

_I don't regularly develop on Windows, so if you encounter any bugs, please let me know through a **well-documented** issue and I'll try my best to get it resolved._

### Can I use another VM instead of Graft?
Definitely. If you want to use `tj` with Nginx and say, [VVV](https://github.com/Varying-Vagrant-Vagrants/VVV), it's as simple as running `tj` with a few flags:

```bash
tj new --vm-box git@github.com:Varying-Vagrant-Vagrants/VVV.git --vm-ip 192.168.50.4 --nginx
```

To use these permanently, set the appropriate `ENV` variables through your `.bashrc` or similar, i.e. `export TJ_VM_BOX=git@github.com:Varying-Vagrant-Vagrants/VVV.git`, `export TJ_VM_IP=192.168.50.4` and `export TJ_NGINX=true`.

_Note: Before running this, you might want to either choose a new `vm-path`, or destroy and remove any existing VMs inside of your `~/tj-vagrant` directory. If `tj` detects that a VM already installed, it will skip installing the new box._

### So, does that mean I can use any Vagrant box?
Yes and no; in order for `tj` to properly create a project, the Vagrant box needs to follow the same directory structure as [Graft](https://github.com/themejuice/graft), and include logic for a `Customfile`. Here is the required structure that `tj` needs in order to be able to create new projects:

```
├── config/
|  |
|  ├── {apache,nginx}-config/
|  |  |
|  |  ├── sites/
|  |  |  |
|  |  |  ├── site-1.conf
|  |  |  ├── site-2.conf
|  |  |  ..
|  |  ..
|  ├── database/
|  |  |
|  |  ├── init-custom.sql
|  |  ..
|  ..
├── www/
|  |
|  ├── site-1/
|  |  |
|  |  ├── index.php
|  |  ..
|  ├── site-2/
|  |  |
|  |  ├── index.php
|  |  ..
|  ..
├── Customfile
├── Vagrantfile
...
```

### What is a `Customfile`?
[It's a file that contains custom rules to add into the main `Vagrantfile`, without actually having to modify it](https://github.com/themejuice/graft/blob/master/Vagrantfile?ts=2). This allows us to easily modify the Vagrant box without causing merge conflicts if you were to update the VM source via `git pull`. Every file that `tj` modifies is _meant to be modified_, so at any time you may update your installation of Graft with a simple `git pull` without getting merge conflicts out the wazoo.

### What is a `Juicefile`?
A YAML configuration file called a `Juicefile` can be used to store commonly-used build scripts, similar to [npm scripts](https://docs.npmjs.com/misc/scripts). Each command can be mapped to any build script you like, allowing you to define a set of commands that can be used across all of your projects. If you plan to deploy using `tj`, this file will also house your [deployment configuration](http://cli.themejuice.it/deploy).

For reference, below is an example config: (see the config for our starter template, [Sprout](https://github.com/themejuice/sprout))

```yml
# Project configuration
project:
  name: example
  url: example.dev

# Manage command aliases for the current project
commands:

  # Run project install scripts
  install:
    - npm install
    - grunt build

  # Manage build tools
  dev:
    - grunt %args%

  # Manage front-end dependencies
  asset:
    - npm %args%

  # Manage back-end dependencies
  vendor:
    - composer %args%

  # Create a backup of the current database with a nice timestamp
  backup:
    - mkdir -p backup
    - wp @development db export backup/$(date +'%Y-%m-%d-%H-%M-%S').sql

# Manage deployment settings for the current project
deployment:
  # …

  stages:
    # …
```

Each command within the above example can be run from the command-line via `tj <command>`. For example, we can run the `tj dev` command, which will in turn run the command `grunt`. Pretty simple, right?

If you happened to have noticed in the example above, there are a few sub-commands that contain `%args%`; these are called placeholders. Each sub-command list is run within a single execution via joining: `cmd1 && cmd2 && cmd3 && ...`, with all placeholders (`%args%`/`%argN%`) replaced with their corresponding argument index, when available.

Here's a few example commands utilizing placeholders:

```yaml
commands:

  example-command-1:
    # Will contain all arguments joined by a space
    - echo "%args%"

  example-command-2:
    # Will contain each argument mapped to its respective index
    - cat '%arg1% %arg2% %arg3%'
    # Will only map argument 4, while ignoring 1-3
    - pbcopy < "%arg4%"
```

To clarify a little bit more using our first example config, we could run `tj dev build` (notice the `build` argument), and since our `dev` command contains `%args%`, that will in turn run the command `grunt build`; if we run `tj dev` command with the arguments `some:other task`, that would be interpreted and run as `grunt some:other task`.

You can specify an unlimited number of commands with an unlimited number of arguments within your `Juicefile`; however, you should be careful with how this is used. Don't go including `sudo rm -rf %arg1%` in a command, while passing `/` as an argument. Keep it simple. These are meant to make your life easier by helping you manage build tools, not to do fancy scripting.

#### Template strings
You may define ERB template strings within a project starter template's `Juicefile`. These will be replaced when creating a new project.

For example,

```yaml
# Project configuration
project:
  name: <%= name %>
  url: <%= url %>
```

will be replaced with,

```yaml
# Project configuration
project:
  name: example-project
  url: example-project.dev
```

if those were the options chosen during a project creation.

#### Available variables for use
- `name`: Project name
- `location`: Project location
- `url`: Project URL
- `xip_url`: Project xip.io URL
- `template`: Project template repository URL
- `repository`: Initialized repository URL, if available
- `db_host`: Project database host
- `db_name`: Project database name
- `db_user`: Project database user
- `db_pass`: Project database password
- `db_import`: Path to imported database file
- `vm_box`: Virtual machine box URL
- `vm_ip`: Virtual machine IP address
- `vm_revision` Revision hash or branch of VM
- `vm_path`: Virtual machine location on the host machine
- `vm_root`: Web root of the VM on the host machine
- `vm_location`: Project location within the VM on the host machine
- `vm_srv`: Project location within the VM on the guest machine
- `vm_prefix`: Virtual machine project location prefix

### Does `tj` support subdomain multi-sites?
If you're able to use [Landrush](https://github.com/phinze/landrush) for your DNS, then yes. All subdomains will resolve to their parent domain. Landrush comes pre-installed when you create your first project with `tj`. Having said that, unfortunately, if you're on Windows you'll might have to manually add the subdomains to your `/etc/hosts` file due to Landrush not being fully supported yet. If you have the Windows chops, head over there and contribute to Landrush by squashing that bug. I'm sure he would appreciate it!

### Can I access a project from another device (i.e. mobile)?
Yes! Every project created with `tj` will automatically be set up to support using [xip.io](http://xip.io/). If you're using OSX, then everything should work out of the box. If you're not using OSX, then you'll need to point port `80` on your host machine to `8080`; Vagrant cannot do this by default for security reasons.

Once everything is good to go, you can access a project from another device on the same network by going to `<project-name>.<your-hosts-ip-address>.xip.io` e.g. `themejuice.192.168.1.1.xip.io`.

_If you're familiar with forwarding host ports on operating systems other than OSX, check out [this file](https://github.com/themejuice/tj/blob/master/lib/theme-juice/tasks/forward_ports.rb#L34-L51) and make a pull request so that everybody else can benefit from your smarts._

#### Using `ngrok`
You can also use a service like [ngrok](https://ngrok.com/), if you prefer that over xip.io:

```bash
ngrok http -host-header project.dev 80
```

⚠️ With both of these options, you'll need to make sure your WordPress project has a plugin like [Relative URL](https://wordpress.org/plugins/relative-url/) so that your assets and links continue to function correctly.

### Can I add my starter template, ________?
Yes! Just update the `TEMPLATES` constant inside [commands/create.rb](https://github.com/themejuice/tj/blob/master/lib/theme-juice/commands/create.rb#L7-L12) and make a pull request. I'll verify that the template includes a `Juicefile` (not required, but preferred to automate build steps), and that everything looks solid. Until then (or if your template is private), just run the command below to clone your template.

```
tj create --template git@your.repo:link/goes-here.git
```

### Can I integrate my deployments with Slack?
Yes, you can integrate deployment notifications with your teams Slack account by adding the following template to your `Juicefile`:

```yml
deployment:
  # ...

  slack:
    url: https://hooks.slack.com/services/your-token
    username: Deploybot
    channel: "#devops"
    emoji: ":rocket:"

  # ...
```

Check out [capistrano-slackify](https://github.com/onthebeach/capistrano-slackify) for more information.

### Can I use a self-signed SSL cert?
Yes, unless you used the `--no-ssl` flag, `tj` will set up each new site to support SSL, [and the VM will generate a new self-signed certificate](https://github.com/themejuice/graft#automatically-generated-self-signed-ssl-certs). In order to take advantage of it, [you'll need to accept the self-signed certificate on your host machine](https://github.com/themejuice/graft#accepting-a-self-signed-ssl-cert).

### Can I define my own Capistrano tasks?
Yes. Any file within a directory called `deploy/` in your project with extensions `.rb`, `.cap` or `.rake` will be automatically loaded by Capistrano.

For example, within our [starter template](https://github.com/themejuice/theme-juice-starter), you will find a `deploy/` directory, inside is a few example tasks. Open one of them and you'll see an example task invokable by `tj remote <stage> <namespace:task>`.

To learn more about Rake and how you can define your own Capistrano tasks, check out the [official Rake repository](https://github.com/ruby/rake) as well as the [official Capistrano tasks documentation](http://capistranorb.com/documentation/getting-started/tasks/).

If you're interested in checking out `tj`'s predefined tasks, head over [here](https://github.com/themejuice/tj/tree/master/lib/theme-juice/tasks/capistrano). You may override any task with custom functionality by using the same namespace/task name as outlined below,

```ruby
# encoding: UTF-8

Rake::Task["db:push"].clear # Clear previous task

namespace :db do

  desc "Overridden database push task"
  task :push do
    # Your new task here
  end
end
```

### Can I run `wp-cli` commands on my deployment stages?
Sure can, and without the help of `tj`! As of version `0.24`, `wp-cli` does this out of the box. Whenever you create a new site, `tj` will add a file to your project's root directory called `wp-cli.local.yml` that contains something along the lines of:

```yml
@development:
  ssh: vagrant@example.dev/srv/www/tj-example
```

You can then run `wp` commands like this,

```bash
wp @development plugin list
```

Feel free to add your other stages into that file as well!

## Troubleshooting

1. [Help! It won't let me `git clone` anything!](#help-it-wont-let-me-git-clone-anything)
1. [What the heck is an `invalid multibyte char (US-ASCII)`?!](#what-the-heck-is-an-invalid-multibyte-char-us-ascii)
1. [Why are my `.dev` domains resolving to `127.0.53.53`?!](#why-are-my-dev-domains-resolving-to-12705353)

### Help! It won't let me `git clone` anything!
If you're hitting issues related to `git clone`, either cloning the VM or a starter template, then you most likely don't have [SSH-keys for GitHub set up correctly](https://help.github.com/articles/error-permission-denied-publickey/). Either go through that article and assure that you can use Git with the `git@` (`ssh://git@`) protocol, or else you can manually run `tj` with the appropriate flags corresponding to the problem-repository, swapping out `git@github.com:` for `https://github.com/`. For example:

```
tj create --template https://github.com/starter-template/repository.git --vm-box https://github.com/vm-box/repository.git
```

The flag duo above replaces the URLs for the starter template and VM box repositories so that they use `https` instead of the `git` protocol.

Or, you can globally update `git` to **always** swap out `git@github.com:` with `https://github.com/` by modifying your `git config` with this command:

```
git config --global url."https://github.com/".insteadOf "git@github.com:"
```

### What the heck is an `invalid multibyte char (US-ASCII)`?!
For one reason or another, your terminal probably doesn't support UTF-8, so it's throwing a fit. Use the `--no-unicode` flag to disable the unicode characters. If the problem still persists, try running it with the `--boring` flag. That should disable all unicode characters and coloring.

```
tj create --no-unicode # Or: tj create --boring
```

### Why are my `.dev` domains resolving to `127.0.53.53`?!
[Google has applied for control of the `.dev` TLD (top level domain)](https://gtldresult.icann.org/application-result/applicationstatus/applicationdetails/1339). To fix it, you'll need to periodically flush your local DNS cache (I'm honestly not entirely sure why). In the future, we'll probably switch to something like `.localhost`. Here are a few commands to flush your cache on OSX:

```bash
# Yosemite:
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder

# Mountain Lion:
sudo discoveryutil mdnsflushcache; sudo discoveryutil udnsflushcaches
```

_Still having issues? [Yell at me!](https://github.com/themejuice/tj/issues)_

## Contributing
1. First, create a _well documented_ [issue](https://github.com/themejuice/tj/issues) for your proposed feature/bug fix
1. After getting approval for the new feature, [fork the repository](https://github.com/themejuice/tj/fork)
1. Create a new feature branch (`git checkout -b my-new-feature`)
1. Write tests before pushing your changes, then run Rspec (`rake`)
1. Commit your changes (`git commit -am 'add some feature'`)
1. Push to the new branch (`git push origin my-new-feature`)
1. Create a new Pull Request

## License
Please see [LICENSE](https://github.com/themejuice/tj/blob/master/LICENSE) for licensing details.

## Author
Ezekiel Gabrielse, [@ezekkkg](https://twitter.com/ezekkkg), [http://ezekielg.com](http://ezekielg.com)
