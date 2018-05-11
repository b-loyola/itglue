RSpec.describe ITGlue do
  it 'has a version number' do
    expect(ITGlue::VERSION).not_to be nil
  end

  describe '.config' do
    it 'returns an instance of Config' do
      expect(ITGlue.config).to be_an_instance_of(ITGlue::Config)
    end
  end

  describe '.configure' do
    shared_examples_for 'config_accessor' do
      before do
        ITGlue.configure { |config| config.send("#{attribute}=", attr_value) }
      end

      it 'sets the value in the config' do
        expect(ITGlue.config.send(attribute)).to eq attr_value
      end
    end

    context 'when an itglue_api_key is passed in' do
      it_behaves_like 'config_accessor' do
        let(:attribute) { :itglue_api_key }
        let(:attr_value) { 'test_key' }
      end
    end

    context 'when an itglue_api_base_uri is passed in' do
      it_behaves_like 'config_accessor' do
        let(:attribute) { :itglue_api_base_uri }
        let(:attr_value) { 'some_uri' }
      end
    end

    context 'when a logger is passed in' do
      it_behaves_like 'config_accessor' do
        let(:attribute) { :logger }
        let(:attr_value) { ::Logger.new(STDOUT) }
      end
    end

    context 'when a default_page_size is passed in' do
      it_behaves_like 'config_accessor' do
        let(:attribute) { :default_page_size }
        let(:attr_value) { 100 }
      end
    end
  end
end
