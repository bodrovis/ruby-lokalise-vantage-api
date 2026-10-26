# frozen_string_literal: true

RSpec.describe LokaliseVantage::Rest::Projects do
  let(:project_id) { '019d29d9-de47-7a57-ac2d-53194197d213' }
  let(:team_id) { '9ef160a0-d4c7-45f5-ab80-bc9e22e95b12' }

  specify '#project' do
    stub_vantage_request(
      method: :get,
      path: "/projects/#{project_id}",
      fixture: 'projects/fetch.json'
    )

    project = test_client.project(project_id)

    expect(project).to be_a(LokaliseVantage::Models::Project)
    expect(project.project_id).to eq(project_id)
    expect(project.name).to eq('Alice')
    expect(project.base_language['locale']).to eq('en')
    expect(project.target_languages.first['locale']).to eq('fr')
    expect(project.translation_settings['workflowType']).to eq('AI_HUMAN_REVIEW')
    expect(project.content_source_name).to be_nil
  end

  describe '#projects' do
    it 'returns projects list' do
      stub_vantage_request(
        method: :get,
        path: "teams/#{team_id}/projects",
        fixture: 'projects/list.json'
      )

      projects = test_client.projects team_id

      expect(projects).to be_a(LokaliseVantage::Collections::Projects)
      expect(projects.items.size).to eq(4)
      expect(projects).to all(be_a(LokaliseVantage::Models::Project))
      expect(projects.cursor).to eq('eyIxIjo2NDY3NTJ9')
      expect(projects.more?).to be true
      expect(projects.page_count).to eq(4)

      expect(projects[0].project_id).to eq(project_id)
      expect(projects[1].name).to eq('GDrive')
    end

    it 'supports cursor-based pagination' do
      cursor = 'eyIxIjo2NDY3NTJ9'
      query = { limit: 2, after: cursor }

      stub_vantage_request(
        method: :get,
        path: "teams/#{team_id}/projects",
        fixture: 'projects/list_paginated.json',
        query: query
      )

      projects = test_client.projects(team_id, query)

      expect(projects).to be_a(LokaliseVantage::Collections::Projects)
      expect(projects.size).to eq(2)
      expect(projects).to all(be_a(LokaliseVantage::Models::Project))

      expect(projects.page_count).to eq(2)
      expect(projects.cursor).to eq('eyIxIjo2NDY3NTN9')
      expect(projects.more?).to be false

      expect(projects.map(&:name)).to eq(['Webflow demo', 'Braze'])
    end
  end
end
