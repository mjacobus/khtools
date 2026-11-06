# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::ReceiptReader do
  let(:reader) { described_class.new(api_key: 'key') }

  def respond_with(content, status: Net::HTTPOK)
    response = status.new('1.1', '200', '')
    body = { output: [{ type: 'reasoning' }, { type: 'message', content: [content] }] }.to_json
    allow(response).to receive(:body).and_return(body)
    allow(Net::HTTP).to receive(:post).and_return(response)
  end

  def answer(text)
    respond_with({ type: 'output_text', text: })
  end

  def read
    reader.read(image_bytes: 'jpeg-bytes', mime_type: 'image/jpeg')
  end

  it 'returns the values read from the photo' do
    answer('{"is_s24":true,"date":"2026-11-04","congregation_cents":12000,"worldwide_cents":3000}')

    expect(read).to have_attributes(is_s24: true, date: '2026-11-04',
                                    congregation_cents: 12_000, worldwide_cents: 3000)
  end

  it 'authenticates with the account key' do
    answer('{}')

    read

    expect(Net::HTTP).to have_received(:post).with(described_class::URL, anything,
                                                   hash_including('Authorization' => 'Bearer key'))
  end

  it 'sends the image and asks for structured output from the right model' do
    answer('{}')
    image = "data:image/jpeg;base64,#{Base64.strict_encode64('jpeg-bytes')}"

    read

    expect(Net::HTTP).to have_received(:post) do |_uri, body, _headers|
      params = JSON.parse(body)
      expect(params).to include('model' => described_class::MODEL)
      expect(params.dig('text', 'format')).to include('type' => 'json_schema', 'strict' => true)
      expect(params['input'].first['content'].first).to eq('type' => 'input_image',
                                                           'image_url' => image)
    end
  end

  it 'returns nil on refusal' do
    respond_with({ type: 'refusal', refusal: 'no' })

    expect(read).to be_nil
  end

  it 'returns nil on API errors' do
    respond_with({}, status: Net::HTTPTooManyRequests)

    expect(read).to be_nil
  end

  it 'returns nil when the API is unreachable' do
    allow(Net::HTTP).to receive(:post).and_raise(Net::OpenTimeout)

    expect(read).to be_nil
  end

  it 'returns nil on invalid JSON' do
    answer('not json')

    expect(read).to be_nil
  end
end
