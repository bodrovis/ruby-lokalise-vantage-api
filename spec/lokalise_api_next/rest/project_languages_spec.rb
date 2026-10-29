# frozen_string_literal: true

RSpec.describe LokaliseApiNext::Rest::ProjectLanguages do
  let(:project_id) { '019d29d9-de47-7a57-ac2d-53194197d213' }

  describe '#project_languages' do
    it 'returns a collection of project languages' do
      stub_vantage_request(
        method: :get,
        path: "projects/#{project_id}/languages",
        fixture: 'project_languages/list.json'
      )

      languages = test_client.project_languages(project_id)

      expect(languages).to be_a(LokaliseApiNext::Collections::ProjectLanguages)
      expect(languages.size).to eq(2)
      expect(languages).to all(be_a(LokaliseApiNext::Models::ProjectLanguage))

      expect(languages[0].language_id).to eq('019d29d9-de52-7ba2-87c6-b5355ebf9c72')
      expect(languages[0].locale).to eq('en')
      expect(languages[0].language_name).to eq('English')
      expect(languages[0].is_rtl).to be false

      expect(languages[1].locale).to eq('fr')
    end
  end
end
