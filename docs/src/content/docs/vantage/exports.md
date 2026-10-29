---
title: Exports
description: Create, monitor, and download exports from Lokalise Vantage projects.
---

The SDK provides methods for creating exports, listing them, checking their status, and retrieving download URLs.

Exports are processed asynchronously. After creating an export, you can check its status and request a download URL once it has completed.

## Create an export

[API documentation](https://developers.lokalise.com/reference/post_v1-projects-projectid-exports)

Use `create_export` to start exporting a project:

```ruby
export = client.create_export('project-id')

puts export.export_id
puts export.status
```

Returns a `LokaliseApiNext::Models::Vantage::Export` object. The initial status is `IN_PROGRESS`.

By default, the entire project is exported for all available languages. You can restrict the export to specific locales:

```ruby
export = client.create_export(
  'project-id',
  locales: ['fr', 'de-DE']
)
```

Alternatively, specify language IDs:

```ruby
export = client.create_export(
  'project-id',
  languageIds: ['language-id-1', 'language-id-2']
)
```

You can also export specific items, each with its own language selection:

```ruby
export = client.create_export(
  'project-id',
  items: [
    {
      itemId: 'item-id-1',
      locales: ['fr']
    },
    {
      itemId: 'item-id-2',
      locales: ['de-DE']
    }
  ]
)
```

The `locales`, `languageIds`, and `items` options represent alternative export selections. Refer to the API documentation for supported combinations and limits.

## List exports

[API documentation](https://developers.lokalise.com/reference/get_v1-projects-projectid-exports)

Use `exports` to retrieve exports belonging to a project:

```ruby
exports = client.exports('project-id')

exports.each do |export|
  puts "#{export.export_id}: #{export.status}"
end
```

Returns a `LokaliseApiNext::Collections::Vantage::Exports` collection containing `LokaliseApiNext::Models::Vantage::Export` objects.

You can filter exports by status:

```ruby
exports = client.exports(
  'project-id',
  'filter-status': 'COMPLETED',
  limit: 20
)
```

Supported statuses are `IN_PROGRESS`, `COMPLETED`, and `FAILED`. You can also filter by export IDs using `filter-ids`.

### Pagination

The `exports` method supports cursor-based pagination.

For example, retrieve up to 20 exports:

```ruby
exports = client.exports('project-id', limit: 20)
```

To retrieve the next page, pass the returned cursor:

```ruby
if exports.more?
  next_page = client.exports(
    'project-id',
    limit: 20,
    after: exports.cursor
  )
end
```

When filtering exports, preserve the filter parameters in subsequent requests.

## Retrieve an export

[API documentation](https://developers.lokalise.com/reference/get_v1-projects-projectid-exports-exportid)

Use `export` to retrieve the current status and details of a specific export:

```ruby
export = client.export('project-id', 'export-id')

puts export.export_id
puts export.status
puts export.created_at
puts export.total_items_count
puts export.processed_items_count
puts export.fail_reason
```

Returns a `LokaliseApiNext::Models::Vantage::Export` object.

An export can have one of three statuses:

- `IN_PROGRESS` — The export is still being processed.
- `COMPLETED` — Processing has finished. Check `processed_items_count` against `total_items_count`, as some selected items may not have been exported.
- `FAILED` — The export failed. Check `fail_reason` for details.

The SDK does not automatically poll for export completion. You can call `export` again to check the latest status.

## Get an export download URL

[API documentation](https://developers.lokalise.com/reference/get_v1-projects-projectid-exports-exportid-download-url)

Use `export_download_url` to retrieve the download URL for a completed export:

```ruby
result = client.export_download_url('project-id', 'export-id')

puts result.download_url
```

Returns a `LokaliseApiNext::Models::Vantage::ExportDownloadUrl` object.

The URL is temporary, so retrieve a new one if it expires. The SDK returns the URL but does not automatically download the exported file.

If the export is still being processed or no downloadable file is available, the API may return an error, which the SDK handles through `LokaliseApiNext::Error`.

## Example: Create and download an export

Here's how the methods fit together:

```ruby
export = client.create_export(
  'project-id',
  locales: ['fr']
)

# Check the status later.
export = client.export('project-id', export.export_id)

if export.status == 'COMPLETED'
  result = client.export_download_url(
    'project-id',
    export.export_id
  )

  puts result.download_url
elsif export.status == 'FAILED'
  puts export.fail_reason
end
```

For more information about request parameters and response fields, refer to the linked API documentation.