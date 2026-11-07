# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Client do
  let(:client) { described_class.new(token: 'TOKEN') }
  let(:buttons) { [[['✅', 'fin:confirm:1']]] }
  let(:button) { { 'text' => '✅', 'callback_data' => 'fin:confirm:1' } }

  def respond_with(body)
    allow(Net::HTTP).to receive(:post).and_return(instance_double(Net::HTTPOK, body: body.to_json))
  end

  it 'returns the id of the sent message' do
    respond_with(ok: true, result: { message_id: 77 })

    expect(client.send_message(chat_id: -100, text: 'oi', reply_to: 5, buttons:)).to eq(77)
  end

  it 'sends a message with buttons as a reply' do
    respond_with(ok: true, result: { message_id: 77 })

    client.send_message(chat_id: -100, text: 'oi', reply_to: 5, buttons:)

    expect(Net::HTTP).to have_received(:post) do |uri, body, headers|
      expect(uri.to_s).to eq('https://api.telegram.org/botTOKEN/sendMessage')
      expect(headers).to include('Content-Type' => 'application/json')
      expect(JSON.parse(body)).to include(
        'chat_id' => -100, 'text' => 'oi', 'reply_markup' => { 'inline_keyboard' => [[button]] },
        'reply_parameters' => { 'message_id' => 5, 'allow_sending_without_reply' => true }
      )
    end
  end

  it 'sends and edits HTML when asked' do
    respond_with(ok: true, result: { message_id: 79 })

    client.send_message(chat_id: -100, text: '<a href="x">y</a>', html: true)
    client.edit_message(chat_id: -100, message_id: 79, text: '<b>z</b>', html: true)

    expect(Net::HTTP).to have_received(:post).twice do |_uri, body, _headers|
      expect(JSON.parse(body)).to include('parse_mode' => 'HTML')
    end
  end

  it 'asks for a forced reply' do
    respond_with(ok: true, result: { message_id: 78 })

    client.send_message(chat_id: -100, text: 'corrija', force_reply: true)

    expect(Net::HTTP).to have_received(:post) do |_uri, body, _headers|
      # not selective: the prompt replies to the bot's own message, so selective would
      # target the bot and open the reply box for nobody
      expect(JSON.parse(body)['reply_markup']).to eq('force_reply' => true)
    end
  end

  it 'raises when Telegram says ok: false' do
    respond_with(ok: false, description: 'Bad Request: chat not found')

    expect { client.answer_callback(id: 'x') }
      .to raise_error(described_class::Error, /chat not found/)
  end

  it 'downloads a file in two steps' do
    respond_with(ok: true, result: { file_path: 'photos/file_1.jpg' })
    allow(Net::HTTP).to receive(:get_response)
      .with(URI('https://api.telegram.org/file/botTOKEN/photos/file_1.jpg'))
      .and_return(instance_double(Net::HTTPOK, code: '200', body: 'bytes'))

    expect(client.download(file_id: 'abc')).to eq('bytes')
  end

  it 'reads updates' do
    respond_with(ok: true, result: [{ update_id: 1 }])

    expect(client.get_updates(offset: 1, timeout: 0)).to eq([{ 'update_id' => 1 }])
  end

  it 'lists the people administering a chat, without bots' do
    respond_with(ok: true, result: [{ user: { id: 1, first_name: 'Ana', last_name: 'Reis' } },
                                    { user: { id: 2, first_name: 'Robô', is_bot: true } }])

    expect(client.chat_administrators(chat_id: -5)).to eq([{ id: 1, name: 'Ana Reis' }])
    expect(Net::HTTP).to have_received(:post)
      .with(URI('https://api.telegram.org/botTOKEN/getChatAdministrators'), { chat_id: -5 }.to_json,
            anything)
  end
end
