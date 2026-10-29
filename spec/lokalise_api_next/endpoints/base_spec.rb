# frozen_string_literal: true

RSpec.describe LokaliseApiNext::Endpoints::Base do
  subject { described_class }

  describe '#build_path' do
    let(:pattern) { '/projects/{project_id}/items/{item_id}' }

    def build_path(**params)
      subject.send(:build_path, pattern, **params)
    end

    it 'expands path parameters' do
      path = build_path(project_id: '123', item_id: '456')

      expect(path).to eq('/projects/123/items/456')
    end

    it 'raises an error for missing parameters' do
      expect { build_path(project_id: '123') }
        .to raise_error(ArgumentError, /item_id/)
    end

    it 'raises an error for nil parameters' do
      expect { build_path(project_id: nil, item_id: '456') }
        .to raise_error(ArgumentError, /project_id/)
    end

    it 'raises an error for empty parameters' do
      expect { build_path(project_id: '', item_id: '456') }
        .to raise_error(ArgumentError, /project_id/)
    end

    it 'encodes reserved characters' do
      path = build_path(project_id: 'abc/def', item_id: '456')

      expect(path).to eq('/projects/abc%2Fdef/items/456')
    end
  end
end
