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

Create a new theme and development site:
```bash
tj create [<theme-name>]
```

Create a new development site without starter theme:
```bash
tj setup [<theme-name>]
```

Delete a theme from the VM: _(Does not remove your local theme)_
```bash
tj delete <theme-name>
```

Watch and compile assets:
```bash
tj watch
tj watch -p <plugin>
```

Optimize images:
```bash
tj optimize
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
