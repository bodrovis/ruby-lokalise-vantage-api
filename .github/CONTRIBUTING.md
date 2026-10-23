# Contributing to Lokalise Vantage Ruby SDK

Thanks for your interest in contributing to the Lokalise Vantage Ruby SDK! Bug reports, improvements, and pull requests are welcome.

## Getting started

You'll need:

- Ruby 3.4 or newer
- Bundler

Clone the repository and install the dependencies:

```bash
git clone https://github.com/bodrovis/ruby-lokalise-vantage-api.git
cd ruby-lokalise-vantage-api
bundle install
```

## Running tests

We use [RSpec](https://rspec.info/) for testing and [WebMock](https://github.com/bblimke/webmock) for mocking HTTP requests.

Run the entire test suite:

```bash
bundle exec rspec
```

To run a specific test file:

```bash
bundle exec rspec spec/models/content_unit_spec.rb
```

Please add or update tests when introducing new features or fixing bugs. Tests should not require access to the live Lokalise Vantage API unless explicitly designed as integration tests.

## Code quality

We use several tools to maintain code quality.

### RuboCop

[RuboCop](https://rubocop.org/) checks coding style and identifies potential problems.

```bash
bundle exec rubocop
```

To automatically fix supported offenses:

```bash
bundle exec rubocop -A
```

Review automatic changes before committing them.

### Reek

[Reek](https://github.com/troessner/reek) detects potential code smells and design issues.

```bash
bundle exec reek lib/
```

Not every warning necessarily indicates a problem. Use your judgment when addressing code smells.

### Dependency security

We use [bundler-audit](https://github.com/rubysec/bundler-audit) to check dependencies against known security vulnerabilities.

```bash
bundle exec bundle-audit check --update
```

This updates the vulnerability database and checks the dependencies resolved in `Gemfile.lock`.

### Test coverage

[SimpleCov](https://github.com/simplecov-ruby/simplecov) collects code coverage when running the test suite.

Coverage reports are generated in the `coverage/` directory.

## Submitting changes

1. Create a branch for your changes.
2. Implement your changes and add relevant tests.
3. Run RSpec, RuboCop, Reek, and bundler-audit.
4. Commit your changes with a descriptive commit message.
5. Open a pull request against the repository.

Keep pull requests focused on a specific change whenever possible. Describe what changed, why it was necessary, and how it was tested.

For larger changes or new features, consider opening an issue first to discuss the proposed approach.

## Reporting bugs

When reporting a bug, please include:

- A description of the problem and the expected behavior.
- Steps to reproduce the issue.
- Your Ruby and SDK versions.
- Relevant error messages or a minimal code example.

Please don't include API tokens, credentials, or other sensitive information in issues or pull requests.

## License

By contributing to this project, you agree that your contributions will be licensed under the [BSD 3-Clause License](LICENSE).