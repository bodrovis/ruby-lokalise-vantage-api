---
title: Project items
description: List and retrieve project items using the Lokalise Vantage Ruby SDK.
---

## List project items

[API documentation](https://developers.lokalise.com/reference/get_v1-projects-projectid-items-1)

Use `project_items` to retrieve items belonging to a project:

```ruby
items = client.project_items('project-id')

items.each do |item|
  puts "#{item.id}: #{item.name}"
end
```

Returns a `LokaliseApiNext::Collections::Vantage::ProjectItems` collection containing `LokaliseApiNext::Models::Vantage::ProjectItem` objects.

You can access individual item attributes:

```ruby
item = items.first

puts item.id
puts item.project_id
puts item.name
puts item.created_at
puts item.updated_at
```

### Pagination

The `project_items` method supports cursor-based pagination.

Retrieve up to 20 items:

```ruby
items = client.project_items('project-id', limit: 20)
```

To retrieve the next page, pass the cursor returned by the previous response:

```ruby
if items.more?
  next_page = client.project_items(
    'project-id',
    limit: 20,
    after: items.cursor
  )
end
```