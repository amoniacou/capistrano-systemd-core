# Capistrano::Systemd::Core

SystemD capistrano support

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-systemd-core'
```

And then execute:

    $ bundle

Or install it yourself as:

$ gem install capistrano-systemd-core

## SystemD setup

```bash
loginctl enable-linger deployer_user_name
```

## Usage

Add this line in `Capfile`:
```
require "capistrano/systemd"
```

Set commands which need to run:

```ruby
set :systemd_services, {.
  puma: {
    cmd: 'puma -p 3000',
    cpu_quota: 70,
    memory_max: '1G'
  },
  sidekiq: {
    cmd: 'sidekiq',
    cpu_quota: 30,
    memory_max: '512M'
  }
}
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/amoniacou/capistrano-systemd-core.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

