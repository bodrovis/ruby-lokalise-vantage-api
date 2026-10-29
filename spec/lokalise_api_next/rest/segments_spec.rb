# frozen_string_literal: true

RSpec.describe LokaliseApiNext::Rest::Segments do
  let(:project_id) { '019d29d9-de47-7a57-ac2d-53194197d213' }
  let(:content_unit_id) { '019d29da-3fee-8fad-b137-bb110afc5af0' }
  let(:path) { "projects/#{project_id}/content-units/#{content_unit_id}/segments" }

  describe '#segments' do
    it 'returns a collection of segments' do
      stub_vantage_request(
        method: :get,
        path: path,
        fixture: 'segments/list.json'
      )

      segments = test_client.segments(project_id, content_unit_id)

      expect(segments).to be_a(LokaliseApiNext::Collections::Segments)
      expect(segments.size).to eq(2)
      expect(segments).to all(be_a(LokaliseApiNext::Models::Segment))

      expect(segments.page_count).to eq(2)
      expect(segments.cursor).to eq('019d29da-3333-7333-8333-333333333333')
      expect(segments.more?).to be true

      segment = segments.first

      expect(segment.id).to eq('019d29da-1111-7111-8111-111111111111')
      expect(segment.number).to eq(0)
      expect(segment.value).to eq('Hello world!')
      expect(segment.status).to eq('TRANSLATING')
      expect(segment.last_change_source).to eq('TRANSLATION_MEMORY')
      expect(segment.content_language_id).to eq('019d29d9-de52-7ba2-87c6-b5355ebf9c72')
      expect(segment.content_unit_id).to eq(content_unit_id)
      expect(segment.project_id).to eq(project_id)
      expect(segment.metadata).to eq('prefix' => '<p>', 'suffix' => '</p>')
      expect(segment.created_at).to eq('2026-03-26T11:14:22.114Z')
      expect(segment.updated_at).to eq('2026-03-26T11:14:22.496Z')

      expect(segments.last.number).to eq(1)
      expect(segments.last.value).to eq('Welcome!')
    end

    it 'supports pagination parameters' do
      cursor = '019d29da-3333-7333-8333-333333333333'

      stub_vantage_request(
        method: :get,
        path: path,
        query: { limit: 1, after: cursor },
        fixture: 'segments/list_paginated.json'
      )

      segments = test_client('test-token').segments(
        project_id,
        content_unit_id,
        limit: 1,
        after: cursor
      )

      expect(segments.size).to eq(1)
      expect(segments.first).to be_a(LokaliseApiNext::Models::Segment)
      expect(segments.first.value).to eq('Goodbye!')
      expect(segments.first.number).to eq(2)

      expect(segments.page_count).to eq(1)
      expect(segments.cursor).to eq('019d29da-4444-7444-8444-444444444444')
      expect(segments.more?).to be false
    end
  end

  describe '#update_segment' do
    let(:segment_id) { '019d29da-cd10-9b67-afe8-1fd14d0a5dee' }
    let(:update_path) { "projects/#{project_id}/segments/#{segment_id}" }
    let(:url) { "https://api.lokalise.com/vantage/v1/#{update_path}" }

    it 'updates a segment without warnings' do
      stub_vantage_request(
        method: :patch,
        path: update_path,
        fixture: 'segments/update.json'
      )

      segment = test_client('test-token').update_segment(
        project_id,
        segment_id,
        value: 'Updated translation',
        status: 'APPROVED'
      )

      expect(segment).to be_a(LokaliseApiNext::Models::Segment)
      expect(segment.id).to eq(segment_id)
      expect(segment.value).to eq('Updated translation')
      expect(segment.status).to eq('APPROVED')
      expect(segment.warnings).to be_empty

      expect(
        a_request(:patch, url).with(
          body: Oj.dump(
            { value: 'Updated translation', status: 'APPROVED' },
            mode: :strict
          ),
          headers: { 'Content-Type' => 'application/json' }
        )
      ).to have_been_made.once
    end

    it 'preserves warnings returned by the API' do
      stub_vantage_request(
        method: :patch,
        path: update_path,
        fixture: 'segments/update_warnings.json'
      )

      segment = test_client('test-token').update_segment(
        project_id,
        segment_id,
        value: 'Updated translation'
      )

      expect(segment).to be_a(LokaliseApiNext::Models::Segment)
      expect(segment.value).to eq('Updated translation')
      expect(segment.status).to eq('PENDING_REVIEW')

      expect(segment.warnings.size).to eq(1)
      expect(segment.warnings.first['code']).to eq('TEST_WARNING')
      expect(segment.warnings.first['details']).to eq('field' => 'value')

      expect(
        a_request(:patch, url).with(
          body: Oj.dump({ value: 'Updated translation' }, mode: :strict)
        )
      ).to have_been_made.once
    end
  end
end
