---
title: Projects and project languages
description: List and retrieve Lokalise Vantage projects and their languages.
---

The SDK provides methods for listing and retrieving Lokalise Vantage projects and their associated languages.

## List projects

[API documentation](https://developers.lokalise.com/reference/get_v1-teams-teamid-projects)

Use `projects` to retrieve projects belonging to a team:

```ruby
projects = client.projects('team-id')

projects.each do |project|
  puts "#{project.project_id}: #{project.name}"
end
```

Returns a `LokaliseApiNext::Collections::Vantage::Projects` collection containing `LokaliseApiNext::Models::Vantage::Project` objects.

You can also pass pagination parameters:

```ruby
projects = client.projects('team-id', limit: 20)
```

If more results are available, use the returned cursor to retrieve the next page:

```ruby
if projects.more?
  next_page = client.projects(
    'team-id',
    limit: 20,
    after: projects.cursor
  )
end
```

## Retrieve a project

[API documentation](https://developers.lokalise.com/reference/get_v1-projects-projectid)

Use `project` to retrieve a single project by its ID:

```ruby
project = client.project('project-id')

puts project.name
puts project.description
puts project.base_language['locale']
puts project.target_languages
puts project.translation_settings
```

Returns a `LokaliseApiNext::Models::Vantage::Project` object.

## List project languages

[API documentation](https://developers.lokalise.com/reference/get_v1-projects-projectid-languages)

Use `project_languages` to retrieve all languages associated with a project:

```ruby
languages = client.project_languages('project-id')

languages.each do |language|
  puts "#{language.language_name} (#{language.locale})"
end
```

Each language exposes its identifier, locale, name, and right-to-left writing direction flag:

```ruby
language = languages.first

puts language.language_id
puts language.locale
puts language.language_name
puts language.is_rtl
```

Returns a `LokaliseApiNext::Collections::Vantage::ProjectLanguages` collection containing `LokaliseApiNext::Models::Vantage::ProjectLanguage` objects.

Unlike the projects list, this endpoint does not use cursor-based pagination.