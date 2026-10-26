# frozen_string_literal: true

require File.expand_path('lib/lokalise_vantage/version', __dir__)

Gem::Specification.new do |spec|
  spec.name                  = 'lokalise-vantage'
  spec.version               = LokaliseVantage::VERSION
  spec.authors               = ['Elijah S. Krukowski']
  spec.email                 = ['elskruk@proton.me']
  spec.summary = 'Ruby SDK for the Lokalise Vantage API'
  spec.description = 'A Ruby client for interacting with the Lokalise Vantage API.'
  spec.homepage = 'https://github.com/bodrovis/ruby-lokalise-vantage-api'
  spec.license               = 'BSD-3-Clause'
  spec.required_ruby_version = '>= 3.4'

  spec.files = Dir['README.md', 'LICENSE',
                   'lib/**/*.rb',
                   'lokalise-vantage.gemspec']

  spec.add_dependency 'addressable', '~> 2.9'
  spec.add_dependency 'httpx', '~> 1.9'
  spec.add_dependency 'oj', '~> 3.17'
  spec.add_dependency 'zeitwerk', '~> 2.8'

  spec.metadata = {
    'rubygems_mfa_required' => 'true',
    'source_code_uri' => spec.homepage,
    'bug_tracker_uri' => "#{spec.homepage}/issues",
    'documentation_uri' => "#{spec.homepage}#readme"
  }
end
