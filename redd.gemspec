# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'redd/version'

Gem::Specification.new do |spec| # rubocop:disable Metrics/BlockLength
  spec.name     = 'redd'
  spec.version  = Redd::VERSION
  spec.authors  = ['Avinash Dwarapu']
  spec.email    = ['avinash@dwarapu.me']
  spec.summary  = 'A batteries-included API wrapper for reddit.'
  spec.homepage = 'https://github.com/avinashbot/redd'
  spec.license  = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'http', '~> 5.0'
  spec.add_dependency 'lazy_lazer', '~> 0.8.1'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rubocop', '~> 1.27'
  spec.add_development_dependency 'yard', '~> 0.9.9'

  spec.add_development_dependency 'guard', '~> 2.14'
  spec.add_development_dependency 'guard-rspec', '~> 4.7'
  spec.add_development_dependency 'rspec', '~> 3.5'
  spec.add_development_dependency 'simplecov', '~> 0.13'
  spec.add_development_dependency 'vcr', '~> 6.1'
  spec.add_development_dependency 'webmock', '~> 3.14'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
