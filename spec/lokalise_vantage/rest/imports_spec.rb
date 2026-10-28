# frozen_string_literal: true

RSpec.describe LokaliseVantage::Rest::Imports do
  let(:project_id) { '019d29d9-de47-7a57-ac2d-53194197d213' }
  let(:batch_id) { '3fa85f64-5717-4562-b3fc-2c963f66afa6' }
  let(:import_id) { '019d29da-4444-7444-8444-444444444444' }
  let(:path) { "projects/#{project_id}/imports" }
  let(:url) { "https://api.lokalise.com/vantage/v1/#{path}" }

  describe '#create_import' do
    it 'imports all uploads from a batch' do
      params = { batchId: batch_id }

      stub_vantage_request(
        method: :post,
        path: path,
        status: 202,
        fixture: 'imports/create.json'
      )

      result = test_client('test-token').create_import(project_id, params)

      expect(result).to be_a(LokaliseVantage::Models::Import)
      expect(result.import_id).to eq(import_id)
      expect(result.warnings).to be_empty

      expect(
        a_request(:post, url).with(
          body: Oj.dump(params, mode: :strict),
          headers: { 'Content-Type' => 'application/json' }
        )
      ).to have_been_made.once
    end

    it 'imports selected uploads from a batch' do
      params = {
        uploads: [
          { uploadId: '019d29da-1111-7111-8111-111111111111' },
          { uploadId: '019d29da-2222-7222-8222-222222222222' }
        ]
      }

      stub_vantage_request(
        method: :post,
        path: path,
        status: 202,
        fixture: 'imports/create.json'
      )

      result = test_client('test-token').create_import(project_id, params)

      expect(result).to be_a(LokaliseVantage::Models::Import)
      expect(result.import_id).to eq(import_id)
      expect(result.warnings).to be_empty

      expect(
        a_request(:post, url).with(
          body: Oj.dump(params, mode: :strict),
          headers: { 'Content-Type' => 'application/json' }
        )
      ).to have_been_made.once
    end
  end
end
