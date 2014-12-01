# Theme Juice
Command line interface to scaffold out a new WordPress development environment and site.

## Installation

* Install [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/) for local development.

Install it:
```bash
gem install theme-juice-cli
```

## Usage

List available commands:
```bash
tj
```

Setup VVV: _(This is automatically run when you create your first site)_
```bash
tj init
```

Create a new development site:
```bash
tj create [<site-name>]
```

Create a new development site without starter theme:
```bash
tj setup [<site-name>] # Alias for `tj create [<site-name>] --bare`
```

Delete a site from the VM: _(Does not remove your local site)_
```bash
tj delete <site-name>
```

Watch and compile assets:
```bash
tj watch
tj watch -p <plugin>
```

List commands for Vagrant: _(development environment)_
```bash
tj vm
```

List commands for Composer: _(dependencies)_
```bash
tj vendor
```

List commands for Mina: _(deployment)_
```bash
tj server
```

## Contributing

1. Fork it ( https://github.com/ezekg/theme-juice-cli/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
