---
title: Tasks
description: List and inspect tasks, assignments, and progress in Lokalise Vantage projects.
---

The SDK provides methods for working with tasks in Lokalise Vantage projects.

## List tasks

[API documentation](https://developers.lokalise.com/reference/get_v1-teams-teamid-projects-projectid-tasks)

Use `tasks` to retrieve tasks belonging to a project:

```ruby
tasks = client.tasks('team-id', 'project-id')

tasks.each do |task|
  puts "#{task.public_id}: #{task.title} (#{task.status})"
end
```

Returns a `LokaliseApiNext::Collections::Vantage::Tasks` collection containing `LokaliseApiNext::Models::Vantage::Task` objects.

You can access individual task attributes:

```ruby
task = tasks.first

puts task.id
puts task.public_id
puts task.title
puts task.type
puts task.status
puts task.description
puts task.task_assignments
puts task.due_date
puts task.created_at
puts task.requested_by
```

### Task assignments

The `task_assignments` attribute contains an array of hashes with assignment details, including assignees and progress:

```ruby
task.task_assignments.each do |assignment|
  puts assignment['languageId']
  puts assignment['progress']['completedWords']
  puts assignment['progress']['totalWords']
end
```

## Pagination and filtering

The `tasks` method supports cursor-based pagination and several filtering options.

For example, retrieve up to 20 tasks and include segments associated with their assignments:

```ruby
tasks = client.tasks(
  'team-id',
  'project-id',
  limit: 20,
  'include-segments': true
)
```

Set `include-segments` to `true` to include segments associated with each assignment. By default, these arrays are empty.

```ruby
tasks.each do |task|
  task.task_assignments.each do |assignment|
    assignment['segments'].each do |segment|
      puts "#{segment['id']}: #{segment['status']}"
    end
  end
end
```

To retrieve the next page, pass the cursor returned by the previous response:

```ruby
if tasks.more?
  next_page = client.tasks(
    'team-id',
    'project-id',
    limit: 20,
    after: tasks.cursor,
    'include-segments': true
  )
end
```

Other supported filters include:

- `filter-ids` — Filter tasks by their identifiers.
- `filter-item-ids` — Filter tasks associated with specific project items.

Refer to the API documentation for accepted values and limits.