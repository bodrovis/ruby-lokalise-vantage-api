---
title: Vantage client configuration
description: Configure authentication, connections, timeouts, and proxies for the Lokalise Vantage API.
sidebar:
  label: Client configuration
  order: 1
---

The `LokaliseApiNext::ClientVantage` class provides access to the Lokalise Vantage API. It inherits shared HTTP configuration and connection management from `LokaliseApiNext::BaseClient` and exposes Vantage-specific API methods.

Create a Vantage client using `LokaliseApiNext.client_vantage`:

```ruby
require 'lokalise_api_next'

client = LokaliseApiNext.client_vantage(
  ENV.fetch('LOKALISE_VANTAGE_TOKEN')
)
```

The API token is the only required argument. You can customize HTTP connections and API settings by passing additional options.

## Available options

| Option | Default | Description |
|---|---|---|
| `token` | Required | Lokalise API token, passed as the first argument. |
| `token_header` | `'x-api-token'` | HTTP header used to send the token. |
| `api_host` | `'https://api.lokalise.com'` | API host. |
| `base_path` | `'/vantage/v1'` | Vantage API path prefix. |
| `timeout` | `nil` | Request timeout in seconds. |
| `open_timeout` | `nil` | Connection establishment timeout in seconds. |
| `persistent` | `false` | Enables persistent HTTP connections. |
| `proxy` | `nil` | Proxy server URL. |

When a timeout is `nil`, the SDK uses the corresponding HTTPX default.

For example, to configure timeouts and persistent connections:

```ruby
client = LokaliseApiNext.client_vantage(
  ENV.fetch('LOKALISE_VANTAGE_TOKEN'),
  timeout: 30,
  open_timeout: 10,
  persistent: true
)
```

The Vantage client uses `/vantage/v1` as its default API path. You generally don't need to change `api_host`, `base_path`, or `token_header` unless you're connecting through a custom API gateway or testing environment.

All client settings are established during initialization. To use different settings, create another client instance.

## Timeouts

You can configure request and connection timeouts separately:

```ruby
client = LokaliseApiNext.client_vantage(
  ENV.fetch('LOKALISE_VANTAGE_TOKEN'),
  timeout: 120,
  open_timeout: 15
)
```

`open_timeout` controls how long HTTPX can spend establishing a connection, while `timeout` limits the duration of an HTTP request.

Both values are specified in seconds. You can omit either option to use the default HTTPX behavior.

## Automatic retries

The SDK uses HTTPX's retries plugin to recover from certain network and connection failures.

By default, HTTPX allows up to three retries when a request meets its retry conditions. Retries apply to idempotent HTTP methods, such as `GET`, `PUT`, and `DELETE`. Methods such as `POST` and `PATCH` are not automatically retried.

This helps avoid accidentally repeating operations that modify data. For example, retrying a project creation request could create duplicate resources if the original request succeeded but its response was lost.

HTTP error responses such as 429 (Too Many Requests) or 500 (Internal Server Error) do not automatically trigger retries solely because of their status.

No additional configuration is required to enable the SDK's default retry behavior.

## Persistent connections

By default, the SDK does not keep HTTP connections open between separate requests.

For applications that make frequent API calls using the same client, you can enable persistent connections:

```ruby
client = LokaliseApiNext.client_vantage(
  ENV.fetch('LOKALISE_VANTAGE_TOKEN'),
  persistent: true
)
```

With persistence enabled, HTTPX can reuse existing connections for subsequent requests, avoiding repeated TCP and TLS connection setup when possible.

This can be useful for long-running applications, background workers, or services that frequently communicate with Vantage.

### Closing connections

Call `close` to release the client's HTTP connections when they are no longer needed:

```ruby
client = LokaliseApiNext.client_vantage(
  ENV.fetch('LOKALISE_VANTAGE_TOKEN'),
  persistent: true
)

begin
  projects = client.projects('team-id')
  puts projects.map(&:name)
ensure
  client.close
end
```

The `close` method is available regardless of whether persistent connections are enabled.

If the same client is shared between threads, make sure all active requests have finished before closing it.

## Proxy configuration

To route requests through a proxy server, provide its URL using the `proxy` option:

```ruby
client = LokaliseApiNext.client_vantage(
  ENV.fetch('LOKALISE_VANTAGE_TOKEN'),
  proxy: 'http://localhost:8080'
)
```

The SDK enables HTTPX's proxy plugin when this option is supplied.

HTTPX supports several proxy protocols, including HTTP, HTTPS, and SOCKS5:

```ruby
client = LokaliseApiNext.client_vantage(
  ENV.fetch('LOKALISE_VANTAGE_TOKEN'),
  proxy: 'socks5://localhost:1080'
)
```

Proxy configuration can be useful when requests must pass through a corporate network gateway or a dedicated outbound proxy.

You can also combine proxy configuration with persistent connections:

```ruby
client = LokaliseApiNext.client_vantage(
  ENV.fetch('LOKALISE_VANTAGE_TOKEN'),
  proxy: 'http://localhost:8080',
  persistent: true
)
```

## Custom API host and base path

The API host and path prefix can be overridden independently:

```ruby
client = LokaliseApiNext.client_vantage(
  'test-token',
  api_host: 'http://localhost:3000',
  base_path: '/vantage/v1'
)
```

This is mainly useful when testing against a mock API server or working with a custom deployment environment.

For normal Vantage API requests, keep the default values:

- API host: `https://api.lokalise.com`
- Base path: `/vantage/v1`