RSpec.describe ITGlue::Client::PathProcessor do
  describe '#path' do
    context 'when only an asset_type is provided' do
      let(:path_processor) { described_class.new(:configurations) }
      it 'returns the correct path' do
        expect(path_processor.path).to eq '/configurations'
      end
    end

    context 'when an id is provided' do
      let(:path_processor) { described_class.new(:configurations, id: id) }
      let(:id) { 1 }
      it 'returns the correct path' do
        expect(path_processor.path).to eq '/configurations/1'
      end
    end

    context 'when a parent is provided' do
      let(:parent) do
        org = ITGlue::Organization.new
        org.id = 2
        org
      end
      let(:path_processor) { described_class.new(:configurations, parent: parent) }

      it 'returns the correct path' do
        expect(path_processor.path).to eq '/organizations/2/relationships/configurations'
      end
    end

    context 'when a parent and id are provided' do
      let(:parent) do
        org = ITGlue::Organization.new
        org.id = 2
        org
      end
      let(:id) { 1 }
      let(:path_processor) { described_class.new(:configurations, parent: parent, id: id) }

      it 'returns the correct path' do
        expect(path_processor.path).to eq '/organizations/2/relationships/configurations/1'
      end
    end
  end
end