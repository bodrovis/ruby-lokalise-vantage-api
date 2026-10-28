# frozen_string_literal: true

RSpec.describe LokaliseVantage::Models::Base do
  let(:model_class) do
    klass = Class.new(described_class) do
      attr_reader :id, :project_id
    end

    klass.tap do |klass|
      klass.const_set(:ATTRIBUTES, %i[id project_id].freeze)
    end
  end

  describe '#initialize' do
    it 'maps JSON attributes to Ruby readers' do
      model = model_class.new(
        {
          'id' => '123',
          'projectId' => '456'
        }
      )

      expect(model.id).to eq('123')
      expect(model.project_id).to eq('456')
    end

    it 'uses empty warnings by default' do
      model = model_class.new({ 'id' => '123' })

      expect(model.warnings).to eq([])
    end

    it 'accepts warnings explicitly' do
      warnings = [{ 'code' => 'TEST_WARNING', 'details' => {} }]
      model = model_class.new({ 'id' => '123' }, warnings: warnings)

      expect(model.warnings).to eq(warnings)
    end
  end

  describe '.from_response' do
    it 'extracts data and preserves warnings' do
      warnings = [{ 'code' => 'TEST_WARNING', 'details' => {} }]

      response = {
        'data' => {
          'id' => '123',
          'projectId' => '456'
        },
        'warnings' => warnings
      }

      model = model_class.from_response(response)

      expect(model.id).to eq('123')
      expect(model.project_id).to eq('456')
      expect(model.warnings).to eq(warnings)
    end

    it 'uses empty warnings when the response has none' do
      model = model_class.from_response(
        'data' => { 'id' => '123' }
      )

      expect(model.warnings).to eq([])
    end

    it 'raises an error when response data is missing' do
      expect { model_class.from_response({}) }.to raise_error(KeyError)
    end
  end
end
