# frozen_string_literal: true

RSpec.describe LokaliseApiNext::Rest::Tasks do
  let(:team_id) { '3fa85f64-5717-4562-b3fc-2c963f66afa6' }
  let(:project_id) { '019d29d9-de47-7a57-ac2d-53194197d213' }
  let(:path) { "teams/#{team_id}/projects/#{project_id}/tasks" }

  describe '#tasks' do
    # rubocop:disable-next RSpec/MultipleExpectations
    it 'returns a collection of tasks' do
      stub_vantage_request(
        method: :get,
        path: path,
        fixture: 'tasks/list.json'
      )

      tasks = test_client('test-token').tasks(team_id, project_id)

      expect(tasks).to be_a(LokaliseApiNext::Collections::Tasks)
      expect(tasks.size).to eq(2)
      expect(tasks).to all(be_a(LokaliseApiNext::Models::Task))

      expect(tasks.page_count).to eq(2)
      expect(tasks.cursor).to eq('3fa85f64-5717-4562-b3fc-2c963f66afa6')
      expect(tasks.more?).to be true

      task = tasks.first

      expect(task.id).to eq('task-123')
      expect(task.public_id).to eq('TASK-1')
      expect(task.title).to eq('Review French translations')
      expect(task.type).to eq('review')
      expect(task.status).to eq('created')
      expect(task.description).to eq('Review the latest translations')
      expect(task.due_date).to eq('2026-11-10T12:00:00.000Z')
      expect(task.created_at).to eq('2026-10-28T14:21:05.694Z')
      expect(task.requested_by).to eq(team_id)

      assignment = task.task_assignments.first

      expect(assignment['languageId']).to eq('language-123')
      expect(assignment['assignees'].first['type']).to eq('user')
      expect(assignment['assignees'].first['contributorId']).to eq(team_id)
      expect(assignment['progress']['completedWords']).to eq(15)
      expect(assignment['progress']['totalWords']).to eq(100)
      expect(assignment['segments']).to be_empty

      expect(tasks.last.public_id).to eq('TASK-2')
      expect(tasks.last.task_assignments).to be_empty
    end

    it 'supports pagination and including segments' do
      cursor = '3fa85f64-5717-4562-b3fc-2c963f66afa6'

      stub_vantage_request(
        method: :get,
        path: path,
        query: {
          limit: 1,
          after: cursor,
          'include-segments': true
        },
        fixture: 'tasks/list_paginated.json'
      )

      tasks = test_client('test-token').tasks(
        team_id,
        project_id,
        limit: 1,
        after: cursor,
        'include-segments': true
      )

      expect(tasks.size).to eq(1)
      expect(tasks.first).to be_a(LokaliseApiNext::Models::Task)
      expect(tasks.first.title).to eq('Review updated content')

      assignment = tasks.first.task_assignments.first
      segment = assignment['segments'].first

      expect(segment['id']).to eq('segment-123')
      expect(segment['unitId']).to eq('unit-123')
      expect(segment['status']).to eq('pending')
      expect(segment['completedAt']).to be_nil

      expect(tasks.page_count).to eq(1)
      expect(tasks.cursor).to eq('3fa85f64-5717-4562-b3fc-2c963f66afa7')
      expect(tasks.more?).to be false
    end
  end
end
