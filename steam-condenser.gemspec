require File.expand_path(File.dirname(__FILE__) + '/lib/steam-condenser/version')

Gem::Specification.new do |s|
  s.name        = 'steam-condenser'
  s.version     = SteamCondenser::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = [ 'Sebastian Staudt' ]
  s.email       = [ 'koraktor@gmail.com' ]
  s.homepage    = 'http://koraktor.de/steam-condenser'
  s.license     = 'BSD'
  s.summary     = 'Steam Condenser - A Steam query library'
  s.description = 'A multi-language library for querying the Steam Community, Source, GoldSrc servers and Steam master servers'

  s.required_ruby_version = '>= 1.9.2'

  s.add_dependency 'multi_json', '~> 1.6'
  s.add_dependency 'multi_xml', '~> 0.5'

  s.add_development_dependency 'mocha', '~> 0.14.0'
  s.add_development_dependency 'rake', '~> 10.1.0'
  s.add_development_dependency 'shoulda-context', '~> 1.1.1'
  s.add_development_dependency 'yard', '~> 0.8.0'

  s.files              = Dir.glob '**/*'
  s.test_files         = Dir.glob 'test/**/*'
  s.require_paths      = [ 'lib' ]
end
