---
title: Content units
description: List and filter content units belonging to project items in Lokalise Vantage.
---

## List content units

[API documentation](https://developers.lokalise.com/reference/get_v1-projects-projectid-items-itemid-content-units-1)

Use `content_units` to retrieve content units belonging to a specific project item:

```ruby
units = client.content_units('project-id', 'item-id')

units.each do |unit|
  puts "#{unit.id}: #{unit.key}"
end
```

Returns a `LokaliseApiNext::Collections::Vantage::ContentUnits` collection containing `LokaliseApiNext::Models::Vantage::ContentUnit` objects.

You can access individual content unit attributes:

```ruby
unit = units.first

puts unit.id
puts unit.project_id
puts unit.type
puts unit.key
puts unit.position
puts unit.source_segments_count
```

### Pagination and filtering

The `content_units` method supports cursor-based pagination and filtering by content unit keys.

For example, retrieve up to 20 content units matching a specific key:

```ruby
units = client.content_units(
  'project-id',
  'item-id',
  limit: 20,
  'filter-keys': 'welcome.title'
)
```

To retrieve the next page, pass the returned cursor while preserving the filter:

```ruby
if units.more?
  next_page = client.content_units(
    'project-id',
    'item-id',
    limit: 20,
    after: units.cursor,
    'filter-keys': 'welcome.title'
  )
end
```

The API supports a maximum of 500 content units per page.