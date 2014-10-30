# Theme Juice

## Installation

* Install [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/) for local development.

Add this line to your application's Gemfile:
```ruby
gem 'theme-juice-cli'
```

And then execute:
```
$ bundle
```

Or install it yourself as:
```
gem install theme-juice-cli
```

## Usage

#### Help
List available commands.

```
tj
```

#### Create theme
Create a new theme and development site.

```
tj create [<theme-name>]
```

#### Delete theme
Delete a theme from the VM. _Does not remove your local theme._

```
tj delete <theme-name>
```

## Contributing

1. Fork it ( https://github.com/ezekg/theme-juice-cli/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
