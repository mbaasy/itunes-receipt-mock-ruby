# -*- encoding: utf-8 -*-

require File.expand_path('../lib/itunes_receipt_mock/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name = 'itunes-receipt-mock'
  gem.required_ruby_version = '>= 1.9.2'
  gem.version = ItunesReceiptMock::VERSION
  gem.summary = 'Mock iTunes Connect receipts'
  gem.description = 'Mock iTunes receipt validation responses for testing'
  gem.license = 'MIT'
  gem.authors = ['mbaasy.com']
  gem.email = 'hello@mbaasy.com'
  gem.homepage = 'https://github.com/mbaasy/itunes-receipt-mock-ruby'
  gem.require_paths = ['lib']

  gem.add_development_dependency 'rake', '~> 10.4'
  gem.add_development_dependency 'activesupport', '~> 4.2'
  gem.add_development_dependency 'rspec', '~> 3.3'
  gem.add_development_dependency 'rubygems-tasks', '~> 0.2'
  gem.add_development_dependency 'timecop', '~> 0.8'
  gem.add_development_dependency 'codeclimate-test-reporter', '~> 0.4'
  gem.add_development_dependency 'rubocop', '~> 0.33'

  # ensure the gem is built out of versioned files
  gem.files = Dir['{bin,lib,man,test,spec}/**/*', 'README*', 'LICENSE*'] &
    `git ls-files -z`.split("\0")
end
