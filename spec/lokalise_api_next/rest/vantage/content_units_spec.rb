# frozen_string_literal: true

RSpec.describe LokaliseApiNext::Rest::Vantage::ContentUnits do
  let(:project_id) { '019d29d9-de47-7a57-ac2d-53194197d213' }
  let(:item_id) { '019d29da-3f21-dad8-0084-175d6fea47d2' }
  let(:path) { "projects/#{project_id}/items/#{item_id}/content-units" }

  describe '#content_units' do
    it 'returns a collection of content units' do
      stub_vantage_request(
        method: :get,
        path: path,
        fixture: 'content_units/list.json'
      )

      units = test_client_vantage('test-token').content_units(project_id, item_id)

      expect(units).to be_a(LokaliseApiNext::Collections::Vantage::ContentUnits)
      expect(units.size).to eq(2)
      expect(units).to all(be_a(LokaliseApiNext::Models::Vantage::ContentUnit))

      expect(units.meta_count).to eq(2)
      expect(units.cursor).to eq('019d29da-2222-7222-8222-222222222222')
      expect(units.more?).to be true

      expect(units[0].id).to eq('019d29da-1111-7111-8111-111111111111')
      expect(units[0].project_id).to eq(project_id)
      expect(units[0].type).to eq('HTML_FILE')
      expect(units[0].key).to eq('welcome.title')
      expect(units[0].position).to eq(0)
      expect(units[0].source_segments_count).to eq(1)

      expect(units[1].key).to eq('welcome.description')
      expect(units[1].position).to eq(1)
      expect(units[1].source_segments_count).to eq(3)
    end

    it 'supports pagination parameters' do
      cursor = '019d29da-2222-7222-8222-222222222222'

      stub_vantage_request(
        method: :get,
        path: path,
        query: { limit: 1, after: cursor },
        fixture: 'content_units/list_paginated.json'
      )

      units = test_client_vantage('test-token').content_units(
        project_id,
        item_id,
        limit: 1,
        after: cursor
      )

      expect(units.size).to eq(1)
      expect(units.first).to be_a(LokaliseApiNext::Models::Vantage::ContentUnit)
      expect(units.first.key).to eq('footer.text')

      expect(units.meta_count).to eq(1)
      expect(units.cursor).to eq('019d29da-3333-7333-8333-333333333333')
      expect(units.more?).to be false
    end
  end
end
