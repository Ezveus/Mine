# Mine

A collaborative editor written in ruby with the configuration and shortcuts in GNU Emacs style.

## Installation

Add this line to your application's Gemfile:

    gem 'Mine'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install Mine

## Usage

Usage: mine-server [OPTIONS]
Launch a mine server
    -h, --host HOST                  TCP authorized distant hosts
    -p, --port PORT                  TCP communication port
    -i, --wshost HOST                WebSocket authorized distant
    hosts
    -q, --wsport PORT                WebSocket communication port
    -j, --rhost HOST                 Rails authorized distant hosts
    -r, --rport PORT                 Rails communication port
    -w, --webclient                  switch to decide if the rails
    server has to be launched
        --help                       displays this screen

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
