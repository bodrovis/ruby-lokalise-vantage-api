---
title: Uploads and imports
description: Stage and upload files, import content, and track translation progress in Lokalise Vantage.
---

The Lokalise Vantage API supports importing files into a project and tracking their translation progress.

Unlike a regular API request, importing files involves several steps:

1. Register files with Vantage to receive temporary upload URLs.
2. Upload the actual file contents directly to S3.
3. Notify Vantage that the uploads are complete.
4. Wait until Vantage finishes processing the uploaded files.
5. Import the files into the project.
6. Track the import and translation statuses.

The Ruby SDK provides methods for interacting with the Vantage API. Uploading file contents to S3 is handled separately using any suitable HTTP client.

## Stage uploads

```ruby
client.stage_uploads(project_id, params)
```

[API documentation](https://developers.lokalise.com/reference/post_v1-projects-projectid-uploads)

Registers up to 100 files for uploading and returns temporary upload targets.

Each file must provide:

- `fileName`: File name including its extension.
- `mimeType`: MIME type of the file.
- `size`: File size in bytes, up to 50 MB.
- `checksum`: MD5 checksum of the file contents, encoded as a hexadecimal string.

For example:

```ruby
require 'digest'

content = "# Hello\n\nThis is a test document.\n"

batch = client.stage_uploads(
  project_id,
  uploads: [
    {
      fileName: 'example.md',
      mimeType: 'text/markdown',
      size: content.bytesize,
      checksum: Digest::MD5.hexdigest(content)
    }
  ]
)

puts batch.batch_id
```

Returns a `LokaliseApiNext::Models::Vantage::UploadBatch` with the following attributes:

- `batch_id`: Identifier of the upload batch.
- `uploads`: Array of upload results.

Each successful entry in `uploads` contains a `fileName`, `uploadId`, `status`, and an `upload` object with a temporary URL, required form fields, and expiration time.

```ruby
batch.uploads.each do |item|
  puts item['fileName']
  puts item['uploadId']
  puts item['status']

  next if item['error']

  puts item['upload']['url']
  puts item['upload']['fields']
  puts item['upload']['expiresAt']
end
```

A file that cannot be staged is returned with an `error` object containing `code` and `message`. Other files in the same request may still be accepted.

To add files to an existing batch, provide its `batchId`:

```ruby
client.stage_uploads(
  project_id,
  batchId: batch.batch_id,
  uploads: [
    {
      fileName: 'another.md',
      mimeType: 'text/markdown',
      size: content.bytesize,
      checksum: Digest::MD5.hexdigest(content)
    }
  ]
)
```

Staging a file with the same name in an existing batch replaces the previous staged upload, provided it has not already been imported.

**Important:** This method only registers files. It does not upload their contents or import them into the project. The returned S3 upload targets are temporary and must be used before they expire.

## Complete uploads

```ruby
client.complete_uploads(project_id, params)
```

[API documentation](https://developers.lokalise.com/reference/post_v1-projects-projectid-uploads-actions-complete)

Notifies Vantage that the file contents have been uploaded to S3.

Complete all pending uploads in a batch:

```ruby
client.complete_uploads(
  project_id,
  batchId: batch.batch_id
)
```

Alternatively, complete specific uploads:

```ruby
client.complete_uploads(
  project_id,
  uploads: [
    { uploadId: upload_id_1 },
    { uploadId: upload_id_2 }
  ]
)
```

You can complete up to 100 specific uploads per request.

The API responds with HTTP `202 Accepted` and no response body, so the SDK returns `nil`.

Completion is asynchronous. Vantage validates and processes the uploaded files in the background.

**Important:** Call this method only after the actual file contents have reached S3. Otherwise, the upload may end in `UPLOAD_FAILED`.

The operation is idempotent: uploads that are no longer `UPLOADING`, or whose completion is already underway, are ignored.

## List uploads

```ruby
client.uploads(project_id, params = {})
```

[API documentation](https://developers.lokalise.com/reference/get_v1-projects-projectid-uploads)

Lists uploads belonging to a project, including their current processing and import statuses.

```ruby
uploads = client.uploads(project_id)

uploads.each do |upload|
  puts "#{upload.file_name}: #{upload.status}"
end
```

Returns a paginated `LokaliseApiNext::Collections::Vantage::Uploads` containing `LokaliseApiNext::Models::Vantage::Upload` objects.

Each upload exposes:

| Attribute | Description |
| --- | --- |
| `upload_id` | Unique upload identifier |
| `batch_id` | Batch containing the upload |
| `file_name` | Original file name |
| `size` | File size in bytes |
| `created_at` | Creation timestamp |
| `status` | Current upload or import status |
| `word_count` | Word count, available after parsing |
| `locale` | Detected source language, available after parsing |
| `item_id` | Project item ID, available after import |
| `error` | Error details, if processing or importing failed |

Possible statuses include:

| Status | Meaning |
| --- | --- |
| `UPLOADING` | Waiting for file upload or processing |
| `UPLOADED` | File has been processed and is ready for import |
| `UPLOAD_FAILED` | File upload or processing failed |
| `IMPORTING` | Import is running |
| `IMPORTED` | File has been imported into the project |
| `IMPORT_FAILED` | Import failed |

The `error` attribute contains a hash with `code` and `message` for failed uploads.

### Filtering uploads

Use `filter-batch-id` to retrieve uploads associated with a particular batch:

```ruby
uploads = client.uploads(
  project_id,
  'filter-batch-id': batch.batch_id
)
```

To retrieve specific uploads, use `filter-ids` with up to 100 identifiers:

```ruby
uploads = client.uploads(
  project_id,
  'filter-ids': "#{upload_id_1},#{upload_id_2}"
)
```

Both filters can be combined.

### Pagination

Supported pagination parameters:

- `limit`: Number of uploads per page, between 1 and 100. Defaults to 100.
- `after`: Cursor returned by the previous page.

```ruby
uploads = client.uploads(project_id, limit: 20)

puts uploads.meta_count
puts uploads.cursor
puts uploads.more?

if uploads.more?
  next_page = client.uploads(
    project_id,
    limit: 20,
    after: uploads.cursor
  )
end
```

`meta_count` represents the number of uploads in the current page, not the total number of uploads in the project.

## Create an import

```ruby
client.create_import(project_id, params)
```

[API documentation](https://developers.lokalise.com/reference/post_v1-projects-projectid-imports)

Imports files that have finished uploading and processing.

Import all eligible uploads in a batch:

```ruby
result = client.create_import(
  project_id,
  batchId: batch.batch_id
)

puts result.import_id
```

Alternatively, import selected uploads:

```ruby
result = client.create_import(
  project_id,
  uploads: [
    { uploadId: upload_id_1 },
    { uploadId: upload_id_2 }
  ]
)
```

All selected uploads must belong to the same batch. A single import can contain up to 100 uploads.

When importing an entire batch, failed and previously imported uploads are excluded. If the batch contains more than 100 eligible uploads, import them in smaller groups using `uploads`.

Returns a `LokaliseApiNext::Models::Vantage::Import`:

- `import_id`: Identifier of the newly created import.

The API responds with HTTP `202 Accepted`. Importing takes place asynchronously.

Use `client.uploads` to track files as they move from `UPLOADED` to `IMPORTING` and finally `IMPORTED`.

Once a file is imported, its `item_id` identifies the corresponding project item.

Files are imported as source content in the project's base language, regardless of the locale detected from their names or contents.

Translation starts automatically after a successful import, according to the project's settings.

**Important:** Do not import a batch while uploads are still being processed. The API may return HTTP `409` with errors such as `BATCH_UPLOAD_IN_PROGRESS` or `UPLOADS_NOT_IMPORTABLE`.

## Get translation status

```ruby
client.translation_status(project_id, import_id)
```

[API documentation](https://developers.lokalise.com/reference/get_v1-projects-projectid-translation-statuses-importid)

Retrieves the translation status of an import, including individual target-language statuses.

```ruby
status = client.translation_status(
  project_id,
  result.import_id
)

puts status.status

status.languages.each do |language|
  puts "#{language['locale']}: #{language['status']}"
end
```

Returns a `LokaliseApiNext::Models::Vantage::TranslationStatus` with the following attributes:

- `project_id`: Project identifier.
- `import_id`: Import identifier.
- `status`: Overall translation status.
- `languages`: Array containing language identifiers, locales, and individual translation statuses.

For example, a translation may still be running for one language while another has already been completed.

The `languages` attribute is an array of hashes:

```ruby
status.languages.each do |language|
  puts language['languageId']
  puts language['locale']
  puts language['status']
end
```

Use this endpoint to monitor translation progress after importing files. A language reaching `COMPLETED` means its translation has finished, including human review if required by the project.

This endpoint is available for file-based Vantage projects and only reports target languages accessible to the current user.

## Complete upload and import workflow

The following example demonstrates the entire workflow using two files: Markdown and HTML.

It performs actual HTTP requests to both Lokalise Vantage and S3:

1. Creates two files in memory.
2. Calculates their sizes and MD5 checksums.
3. Registers them using `stage_uploads`.
4. Uploads their contents directly to S3 using Ruby's `Net::HTTP`.
5. Calls `complete_uploads`.
6. Waits for both files to reach `UPLOADED`.
7. Creates an import.
8. Waits for both files to reach `IMPORTED`.
9. Retrieves the translation status.

No additional gems are required for the S3 upload itself.

### Prerequisites

Set the following environment variables:

- `LOKALISE_VANTAGE_TOKEN`: Your Vantage API token.
- `LOKALISE_VANTAGE_PROJECT_ID`: ID of a file-based Vantage project where you have permission to upload and import files.

**Warning:** This example creates real project content and can trigger translation usage. Run it against a suitable test project.

### Example

```ruby
require 'lokalise_api_next'
require 'digest'
require 'net/http'
require 'securerandom'
require 'stringio'
require 'uri'

project_id = ENV.fetch('LOKALISE_VANTAGE_PROJECT_ID')
client = LokaliseApiNext.client_vantage(ENV.fetch('LOKALISE_VANTAGE_TOKEN'))

# Upload file contents to the temporary S3 target.
# This is a direct S3 request, not a Vantage API call.
def upload_to_s3(staged_upload, file)
  target = staged_upload.fetch('upload')
  fields = target.fetch('fields')
  uri = URI.parse(target.fetch('url'))

  raise 'Expected HTTPS upload URL' unless uri.is_a?(URI::HTTPS)

  expected_md5 = Digest::MD5.base64digest(file[:content])

  unless fields.fetch('Content-MD5') == expected_md5
    raise "MD5 mismatch for #{file[:name]}"
  end

  form = fields.map { |key, value| [key, value.to_s] }
  form << ['Content-Type', file[:mime_type]] unless fields.key?('Content-Type')

  form << [
    'file',
    StringIO.new(file[:content]),
    {
      filename: file[:name],
      content_type: file[:mime_type]
    }
  ]

  request = Net::HTTP::Post.new(uri)
  request.set_form(form, 'multipart/form-data')

  response = Net::HTTP.start(
    uri.host,
    uri.port,
    use_ssl: true,
    open_timeout: 15,
    read_timeout: 60,
    write_timeout: 60
  ) do |http|
    http.request(request)
  end

  raise "S3 upload failed: HTTP #{response.code}" unless response.code.to_i == 204
end

# Poll Vantage until all expected uploads reach the target status.
def wait_for_uploads(client, project_id, batch_id, upload_ids, target:, timeout: 180)
  deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout

  loop do
    uploads = client.uploads(
      project_id,
      'filter-batch-id': batch_id
    )

    items = uploads.select { |upload| upload_ids.include?(upload.upload_id) }

    failed = items.find do |upload|
      %w[UPLOAD_FAILED IMPORT_FAILED].include?(upload.status)
    end

    if failed
      raise "Upload #{failed.file_name} failed: #{failed.error.inspect}"
    end

    if items.size == upload_ids.size &&
       items.all? { |upload| upload.status == target }
      return items
    end

    if Process.clock_gettime(Process::CLOCK_MONOTONIC) >= deadline
      states = items.map { |upload| "#{upload.file_name}: #{upload.status}" }
      raise "Timed out waiting for #{target}: #{states.inspect}"
    end

    sleep 3
  end
end

suffix = SecureRandom.hex(6)

files = [
  {
    name: "vantage-test-#{suffix}.md",
    mime_type: 'text/markdown',
    content: "# Vantage SDK test\n\nHello from the Ruby SDK!\n"
  },
  {
    name: "vantage-test-#{suffix}.html",
    mime_type: 'text/html',
    content: '<!DOCTYPE html><html><body>' \
             '<h1>Vantage SDK test</h1>' \
             '<p>Hello from the Ruby SDK!</p>' \
             '</body></html>'
  }
]

begin
  # Step 1: Register files with Vantage.
  batch = client.stage_uploads(
    project_id,
    uploads: files.map do |file|
      {
        fileName: file[:name],
        mimeType: file[:mime_type],
        size: file[:content].bytesize,
        checksum: Digest::MD5.hexdigest(file[:content])
      }
    end
  )

  puts "Batch: #{batch.batch_id}"

  # Step 2: Upload actual contents to S3.
  upload_ids = batch.uploads.map do |item|
    if item['error']
      raise "Staging failed for #{item['fileName']}: #{item['error'].inspect}"
    end

    file = files.find { |candidate| candidate[:name] == item['fileName'] }
    raise "Local file not found: #{item['fileName']}" unless file

    upload_to_s3(item, file)
    puts "Uploaded to S3: #{file[:name]}"

    item.fetch('uploadId')
  end

  # Step 3: Notify Vantage that uploads are complete.
  client.complete_uploads(
    project_id,
    batchId: batch.batch_id
  )

  # Step 4: Wait until both files are ready for import.
  uploaded = wait_for_uploads(
    client,
    project_id,
    batch.batch_id,
    upload_ids,
    target: 'UPLOADED'
  )

  uploaded.each do |item|
    puts "Ready: #{item.file_name}, words: #{item.word_count}"
  end

  # Step 5: Import the batch.
  imported = client.create_import(
    project_id,
    batchId: batch.batch_id
  )

  puts "Import ID: #{imported.import_id}"

  # Step 6: Wait for import completion.
  imported_uploads = wait_for_uploads(
    client,
    project_id,
    batch.batch_id,
    upload_ids,
    target: 'IMPORTED'
  )

  imported_uploads.each do |item|
    puts "Imported: #{item.file_name}, item ID: #{item.item_id}"
  end

  # Step 7: Check translation progress.
  translation = client.translation_status(
    project_id,
    imported.import_id
  )

  puts "Translation status: #{translation.status}"

  translation.languages.each do |language|
    puts "#{language['locale']}: #{language['status']}"
  end
ensure
  client.close
end
```

### Understanding the workflow

There are two separate asynchronous operations:

**Upload processing:** After calling `complete_uploads`, Vantage processes the uploaded files. Poll `client.uploads` until the files reach `UPLOADED`. Only then should they be imported.

**Import processing:** After calling `create_import`, Vantage imports the files into the project. Poll `client.uploads` until the files reach `IMPORTED`. Each imported upload will have an `item_id`.

Translation then proceeds according to the project settings. The `translation_status` method can be called repeatedly to monitor its progress.

The example polls every three seconds and allows up to 180 seconds for each upload and import processing phase. Adjust these values for larger files or slower operations.

For simplicity, the polling example assumes that the batch contains no more than 100 uploads, so all expected entries fit on one page. For larger batches, handle pagination using `cursor` and `more?`.

### Important considerations

- **S3 uploads are separate from the SDK.** The `upload.url` and `upload.fields` returned by Vantage are used to construct a multipart POST request directly to S3.
- **Preserve the signed form fields.** Do not change or omit fields returned by Vantage. The file must be submitted as the `file` part of the multipart form.
- **Use the correct MD5 encoding.** Vantage staging expects a hexadecimal MD5 checksum. The signed S3 form uses Base64-encoded MD5 in `Content-MD5`.
- **Upload targets expire.** If a target expires, stage the file again to obtain a new one.
- **Handle failures explicitly.** Check individual staging errors, `UPLOAD_FAILED`, and `IMPORT_FAILED`.
- **Do not log signed upload URLs or credentials.** They contain temporary authorization information.
- **Do not assume translation finishes immediately.** A successful import starts translation, but translation and any required review can continue afterward.

The SDK does not provide a dedicated S3 upload method. Any HTTP client capable of sending multipart form data can be used with the upload targets returned by Vantage.