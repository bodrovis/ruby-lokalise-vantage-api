# Ruby SDK for Lokalise API

![Gem](https://img.shields.io/gem/v/lokalise-api-next)
![CI](https://github.com/lokalise/ruby-lokalise-api-next/actions/workflows/ci.yml/badge.svg)
[![Code Coverage](https://qlty.sh/gh/lokalise/projects/ruby-lokalise-api-next/coverage.svg)](https://qlty.sh/gh/lokalise/projects/ruby-lokalise-api-next)
[![Maintainability](https://qlty.sh/gh/lokalise/projects/ruby-lokalise-api-next/maintainability.svg)](https://qlty.sh/gh/lokalise/projects/ruby-lokalise-api-next)

Opinionated Ruby SDK for the [Lokalise Vantage API](https://developers.lokalise.com/reference/lokalise-vantage-api-introduction).

The `lokalise-api-next` gem provides a Ruby interface for working with Lokalise Vantage resources. It handles authentication, HTTP requests, response parsing, and API errors, and returns Ruby models and collections.

## Requirements

- Ruby 3.4 or newer
- A Lokalise API token with access to Vantage

## Installation

Add the gem to your Gemfile:

```ruby
gem 'lokalise-api-next'
```

Then run:

```bash
bundle install
```

## Usage

Create a client using your Lokalise API token:

```ruby
require 'lokalise_api_next'

client_vantage = LokaliseApiNext.client_vantage(
  ENV.fetch('LOKALISE_VANTAGE_TOKEN')
)
```

For example, retrieve a project:

```ruby
project = client_vantage.project('project-id')

puts project.name
puts project.description
```

Or list projects belonging to a team:

```ruby
projects = client_vantage.projects('team-id', limit: 20)

projects.each do |project|
  puts "#{project.project_id}: #{project.name}"
end
```

The SDK also supports configurable timeouts, automatic retries, proxies, and persistent HTTP connections.

## Documentation

See **[lokalise.github.io/ruby-lokalise-api-next/](https://lokalise.github.io/ruby-lokalise-api-next/)** for usage examples, client configuration, pagination, and available API operations.

## Development and testing

Clone the repository and install dependencies:

```bash
bundle install
```

Run the test suite:

```bash
bundle exec rspec
```

Run RuboCop:

```bash
bundle exec rubocop
```

The tests use RSpec and WebMock to simulate API responses, so a real API token is not required.

## License

(c) 2026 Lokalise group, Elijah S. Krukowski, BSD 3 Clause license.
