# frozen_string_literal: true

RSpec.describe LokaliseVantage::Rest::TranslationStatuses do
  let(:project_id) { '019d29d9-de47-7a57-ac2d-53194197d213' }
  let(:import_id) { '019d29da-4444-7444-8444-444444444444' }

  describe '#translation_status' do
    it 'returns the translation status of an import' do
      stub_vantage_request(
        method: :get,
        path: "projects/#{project_id}/translation-statuses/#{import_id}",
        fixture: 'translation_statuses/fetch.json'
      )

      result = test_client('test-token').translation_status(project_id, import_id)

      expect(result).to be_a(LokaliseVantage::Models::TranslationStatus)
      expect(result.project_id).to eq(project_id)
      expect(result.import_id).to eq(import_id)
      expect(result.status).to eq('TRANSLATING')
      expect(result.warnings).to be_empty

      expect(result.languages.size).to eq(2)

      french = result.languages.first
      german = result.languages.last

      expect(french['languageId']).to eq('019d29d9-de52-7ba2-87c6-b5355efd2aa7')
      expect(french['locale']).to eq('fr')
      expect(french['status']).to eq('COMPLETED')

      expect(german['languageId']).to eq('019d29d9-de52-7ba2-87c6-b5355efd2aa8')
      expect(german['locale']).to eq('de')
      expect(german['status']).to eq('TRANSLATING')
    end
  end
end
