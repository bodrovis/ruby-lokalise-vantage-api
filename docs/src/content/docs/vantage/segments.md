---
title: Segments
description: List and update translation segments in Lokalise Vantage projects.
---

The SDK provides methods for listing and updating segments in Lokalise Vantage projects.

## List segments

[API documentation](https://developers.lokalise.com/reference/get_v1-projects-projectid-content-units-contentunitid-segments-1)

Use `segments` to retrieve segments belonging to a content unit:

```ruby
segments = client.segments('project-id', 'content-unit-id')

segments.each do |segment|
  puts "#{segment.number}: #{segment.value}"
end
```

Returns a `LokaliseApiNext::Collections::Vantage::Segments` collection containing `LokaliseApiNext::Models::Vantage::Segment` objects.

You can access individual segment attributes:

```ruby
segment = segments.first

puts segment.id
puts segment.number
puts segment.value
puts segment.status
puts segment.last_change_source
puts segment.content_language_id
puts segment.content_unit_id
puts segment.project_id
puts segment.metadata
puts segment.created_at
puts segment.updated_at
```

### Pagination

The `segments` method supports cursor-based pagination.

For example, retrieve up to 20 segments:

```ruby
segments = client.segments(
  'project-id',
  'content-unit-id',
  limit: 20
)
```

To retrieve the next page, pass the cursor returned by the previous response:

```ruby
if segments.more?
  next_page = client.segments(
    'project-id',
    'content-unit-id',
    limit: 20,
    after: segments.cursor
  )
end
```

## Update a segment

[API documentation](https://developers.lokalise.com/reference/patch_v1-projects-projectid-segments-segmentid)

Use `update_segment` to change a segment's translated value, status, or both:

```ruby
segment = client.update_segment(
  'project-id',
  'segment-id',
  value: 'Updated translation',
  status: 'APPROVED'
)

puts segment.value
puts segment.status
```

Returns a `LokaliseApiNext::Models::Vantage::Segment` object.

At least one of the following parameters must be provided:

- `value` — The new translated value.
- `status` — Either `APPROVED` or `PENDING_REVIEW`.

You can also update only the status:

```ruby
segment = client.update_segment(
  'project-id',
  'segment-id',
  status: 'PENDING_REVIEW'
)
```

### Warnings

The API may return warnings when updating a segment. These are available through the model's `warnings` attribute:

```ruby
segment.warnings.each do |warning|
  puts warning['code']
  puts warning['details']
end
```

If no warnings are returned, `segment.warnings` is an empty array.

### Non-translatable content

Segment values may contain non-translatable content (NTC) enclosed between the Unicode characters `U+E101` and `U+E102`.

Be careful when updating these values. Modifying, moving, or removing NTC fragments may break the format of the exported file.