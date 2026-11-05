# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::ReceiptReader do
  let(:messages) { instance_double(Anthropic::Resources::Messages) }
  let(:client) { instance_double(Anthropic::Client, messages:) }
  let(:reader) { described_class.new(api_key: 'key', client:) }

  def reply(text, stop_reason: :end_turn)
    Anthropic::Models::Message.new(
      id: 'msg', type: :message, role: :assistant, model: :'claude-opus-5-5', stop_reason:,
      content: [{ type: :text, text:, citations: nil }],
      stop_sequence: nil, usage: { input_tokens: 1, output_tokens: 1 }
    )
  end

  def read
    reader.call(image_bytes: 'jpeg-bytes', mime_type: 'image/jpeg')
  end

  it 'returns the values read from the photo' do
    allow(messages).to receive(:create).and_return(
      reply('{"is_s24":true,"date":"2026-11-04","congregation_cents":12000,"worldwide_cents":3000}')
    )

    expect(read).to have_attributes(is_s24: true, date: '2026-11-04',
                                    congregation_cents: 12_000, worldwide_cents: 3000)
  end

  it 'sends the image and asks for structured output from the right model' do
    allow(messages).to receive(:create).and_return(reply('{}'))
    source = { type: :base64, media_type: 'image/jpeg', data: Base64.strict_encode64('jpeg-bytes') }

    read

    expect(messages).to have_received(:create) do |params|
      expect(params).to include(model: :'claude-opus-5-5')
      expect(params.dig(:output_config, :format, :type)).to eq(:json_schema)
      expect(params[:messages].first[:content].first).to eq(type: :image, source:)
    end
  end

  it 'returns nil on refusal' do
    allow(messages).to receive(:create).and_return(reply('', stop_reason: :refusal))

    expect(read).to be_nil
  end

  it 'returns nil on API errors' do
    error = Anthropic::Errors::APIConnectionError.new(url: nil)
    allow(messages).to receive(:create).and_raise(error)

    expect(read).to be_nil
  end

  it 'returns nil on invalid JSON' do
    allow(messages).to receive(:create).and_return(reply('not json'))

    expect(read).to be_nil
  end
end
