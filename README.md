Steam Condenser
===============

[![Gem Version](https://badge.fury.io/rb/steam-condenser.svg)](http://badge.fury.io/rb/steam-condenser)
[![Build Status](https://travis-ci.com/koraktor/steam-condenser-ruby.svg)](http://travis-ci.org/koraktor/steam-condenser-ruby)
[![Code Climate](https://codeclimate.com/github/koraktor/steam-condenser-ruby.svg)](https://codeclimate.com/github/koraktor/steam-condenser-ruby)
[![Coverage Status](https://coveralls.io/repos/koraktor/steam-condenser-ruby/badge.svg)](https://coveralls.io/r/koraktor/steam-condenser-ruby)

The Steam Condenser is a multi-language library for querying the Steam
Community, Source and GoldSrc game servers as well as the Steam master servers.
Currently it is implemented in Java, PHP and Ruby.

## Requirements

* Ruby 2.1 or newer (and compatible Ruby VMs)
* Any operating system able to run such a VM

The following gems are required:

* `bzip2-ruby` (for Source servers sending compressed responses)
* `multi_json` (for the Web API features)
* `multi_xml` (for the Steam Community features)

## Installation

To install Steam Condenser as a Ruby gem use the following command:

```bash
$ gem install steam-condenser
```

If you're project dependencies are managed by [Bundler](http://bundler.io) add
this to your `Gemfile`:

```ruby
gem 'steam-condenser'
```

## Usage

To start using Steam Condenser requiring the base file is usually enough:

```ruby
require 'steam-condenser'
```

## License

This code is free software; you can redistribute it and/or modify it under the
terms of the new BSD License. A copy of this license can be found in the
included LICENSE file.

## Credits

* Sebastian Staudt – koraktor(at)gmail.com
* DeFirence – defirence(at)defirence.za.net
* Mike Połtyn – mike(at)railslove.com
* Sam Kinard – snkinard(at)gmail.com
* "withgod" – noname(at)withgod.jp
* John Amicangelo - amicangelo.j(at)husky.neu.edu
* Eric Litak – elitak(at)gmail.com
* Rodrigo Navarro – rnavarro1(at)gmail.com
* Justas Palumickas – jpalumickas(at)gmail.com
* Philipp Preß – philipp.press(at)blacklane.com
* Arie – git(at)ariekanarie.nl

## See Also

* [Steam Condenser home](https://koraktor.de/steam-condenser)
* [Documentation](https://rubydoc.info/gems/steam-condenser)
* [GitHub project page](https://github.com/koraktor/steam-condenser)
* [Wiki](https://github.com/koraktor/steam-condenser/wiki)
* [Google group](https://groups.google.com/group/steam-condenser)
* [Open Hub profile](https://www.openhub.net/p/steam-condenser)

Follow Steam Condenser on Twitter via
[@steamcondenser](https://twitter.com/steamcondenser).
