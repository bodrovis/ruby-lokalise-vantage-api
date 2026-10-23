# frozen_string_literal: true

RSpec.describe LokaliseVantage::Models::Base do
  describe '#initialize' do
    let(:model_class) do
      klass = Class.new(described_class) do
        attr_reader :id, :project_id
      end

      klass.tap do |klass|
        klass.const_set(:ATTRIBUTES, %i[id project_id].freeze)
      end
    end

    it 'maps JSON attributes to Ruby readers' do
      model = model_class.new(
        'id' => '123',
        'projectId' => '456'
      )

      expect(model.id).to eq('123')
      expect(model.project_id).to eq('456')
    end
  end
end
