source 'https://rubygems.org'

gemspec

group :test do
  gem 'coveralls', :require => false

  if RUBY_VERSION.to_f == 1.8
    gem 'mime-types', '< 2.0.0'
    gem 'rest-client', '< 1.7.0'
    gem 'test-unit', '< 3.1.0'
  end
end
