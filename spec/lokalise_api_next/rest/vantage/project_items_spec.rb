# frozen_string_literal: true

RSpec.describe LokaliseApiNext::Rest::Vantage::ProjectItems do
  let(:project_id) { '019d29d9-de47-7a57-ac2d-53194197d213' }

  describe '#project_items' do
    it 'returns a collection of project items' do
      stub_vantage_request(
        method: :get,
        path: "projects/#{project_id}/items",
        fixture: 'project_items/list.json'
      )

      items = test_client_vantage('test-token').project_items(project_id)

      expect(items).to be_a(LokaliseApiNext::Collections::Vantage::ProjectItems)
      expect(items.size).to eq(2)
      expect(items).to all(be_a(LokaliseApiNext::Models::Vantage::ProjectItem))

      expect(items.page_count).to eq(2)
      expect(items.cursor).to eq('019efe60-00ef-a7a1-c448-74e764fdbdea')
      expect(items.more?).to be false

      expect(items[0].id).to eq('019d29da-3f21-dad8-0084-175d6fea47d2')
      expect(items[0].project_id).to eq(project_id)
      expect(items[0].name).to eq('alice.md')
      expect(items[0].created_at).to eq('2026-03-26T11:14:22.114Z')
      expect(items[0].updated_at).to eq('2026-03-26T11:14:22.496Z')

      expect(items[1].name).to eq('alice.docx')
    end

    it 'supports pagination parameters' do
      cursor = '019efe60-00ef-a7a1-c448-74e764fdbdea'

      stub_vantage_request(
        method: :get,
        path: "projects/#{project_id}/items",
        query: { limit: 1, after: cursor },
        fixture: 'project_items/list_paginated.json'
      )

      items = test_client_vantage('test-token').project_items(
        project_id,
        limit: 1,
        after: cursor
      )

      expect(items.size).to eq(1)
      expect(items.first).to be_a(LokaliseApiNext::Models::Vantage::ProjectItem)
      expect(items.first.name).to eq('notes.txt')

      expect(items.page_count).to eq(1)
      expect(items.cursor).to eq('019eff00-1111-7222-8333-444455556666')
      expect(items.more?).to be false
    end
  end
end
