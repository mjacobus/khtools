# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::CorrectionAssistant do
  let(:assistant) { described_class.new(api_key: 'key') }
  let(:document) do
    Db::FinanceDocument.new(kind: 'unknown', competence: '2026-06',
                            document_date: Date.new(2026, 6, 2))
  end

  def http_response(body)
    Net::HTTPOK.new('1.1', '200', '').tap do |response|
      allow(response).to receive(:body).and_return(body.to_json)
    end
  end

  def answer(fields)
    text = { tipo: '', data: '', mes: '', valor: '', local: '', mundial: '', total: '', desc: '' }
      .merge(fields).to_json
    allow(Net::HTTP).to receive(:post)
      .and_return(http_response(output: [{ content: [{ type: 'output_text', text: }] }]))
  end

  it 'transcribes a voice message' do
    http = instance_double(Net::HTTP)
    allow(Net::HTTP).to receive(:start).and_yield(http)
    allow(http).to receive(:request).and_return(http_response(text: 'auditoria de março a maio'))

    expect(assistant.transcribe(audio: 'ogg-bytes')).to eq('auditoria de março a maio')
    expect(http).to have_received(:request) do |request|
      expect(request['Authorization']).to eq('Bearer key')
      expect(request.path).to eq('/v1/audio/transcriptions')
    end
  end

  it 'turns what was said into the correction fields' do
    answer(tipo: 'audit_report', mes: '2026-05')

    expect(assistant.correction(text: 'auditoria de março a maio', document:))
      .to eq('tipo audit_report mes 2026-05')
  end

  it 'tells the model what the document is now and what was said' do
    answer(desc: 'Luz')

    assistant.correction(text: 'é a conta de luz', document:)

    expect(Net::HTTP).to have_received(:post) do |_url, body, _headers|
      prompt = JSON.parse(body).dig('input', 0, 'content', 0, 'text')
      expect(prompt).to include('é a conta de luz', '"tipo":"unknown"', '"mes":"2026-06"',
                                'audit_report', 'fevereiro, maio, agosto ou novembro')
    end
  end

  it 'says when it did not understand' do
    answer({})

    expect { assistant.correction(text: 'bom dia', document:) }
      .to raise_error(Finance::Correction::Error, 'Não entendi o que corrigir em "bom dia".')
  end

  it 'explains when OpenAI fails' do
    allow(Net::HTTP).to receive(:post).and_return(Net::HTTPInternalServerError.new('1.1', '500',
                                                                                   ''))

    expect { assistant.correction(text: 'auditoria', document:) }
      .to raise_error(Finance::Correction::Error, /OpenAI/)
  end
end
