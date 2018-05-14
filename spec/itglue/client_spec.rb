RSpec.describe ITGlue::Client do
  let(:client) { described_class.new }
  let(:config) { instance_double('ITGlue::Config') }
  let(:api_key) { 'key' }
  let(:page_size) { 10 }
  before do
    allow(ITGlue).to receive(:config).and_return(config)
    allow(config).to receive(:itglue_api_key).and_return(api_key)
    allow(config).to receive(:itglue_api_base_uri).and_return('url')
    allow(config).to receive(:default_page_size).and_return(page_size)
    allow(config).to receive(:logger).and_return(nil)
  end

  describe '#execute' do
    let(:path) { '/configurations' }
    let(:options) { Hash.new }
    let(:custom_headers) { Hash.new }
    let(:expected_headers) { { "Content-Type" => "application/vnd.api+json", "x-api-key" => api_key } }
    let(:payload) { nil }
    let(:expected_options) do
      options = {
        headers: expected_headers.merge(custom_headers),
        query: { page: { size: page_size } }
      }
      payload ? options.merge(body: payload.to_json) : options
    end
    let(:mock_response) { instance_double('HTTParty::Response') }

    before do
      allow(ITGlue::Client).to receive(http_method).with(path, options).and_return(mock_response)
      allow(mock_response).to receive(:success?).and_return(true)
    end

    subject { client.execute(http_method, path, payload, options) }

    context 'get' do
      let(:http_method) { :get }

      it 'returns the expected response' do
        is_expected.to eq mock_response
      end

      it 'sends the expected options' do
        expect(ITGlue::Client).to receive(http_method).with(path, expected_options)
        subject
      end
    end

    context 'post' do
      let(:http_method) { :post }
      let(:payload) { { data: 'some data' } }

      it 'returns the expected response' do
        is_expected.to eq mock_response
      end

      it 'sends the expected options' do
        expect(ITGlue::Client).to receive(http_method).with(path, expected_options)
        subject
      end
    end

    context 'patch' do
      let(:http_method) { :patch }
      let(:payload) { { data: 'some data' } }

      it 'returns the expected response' do
        is_expected.to eq mock_response
      end

      it 'sends the expected options' do
        expect(ITGlue::Client).to receive(http_method).with(path, expected_options)
        subject
      end
    end

    context 'options' do
      let(:http_method) { :get }

      context 'headers' do
        context 'overwriting a default header' do
          let(:custom_headers) { {'Content-Type' => 'application/json', 'My-Header' => '123'} }
          let(:options) { { headers: custom_headers } }

          it 'overwrites the default header and keeps the other defaults' do
            expect(ITGlue::Client).to receive(http_method).with(path, expected_options)
            subject
          end
        end
      end
    end
  end
end