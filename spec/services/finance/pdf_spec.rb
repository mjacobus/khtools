# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::Pdf do
  let(:dir) { Dir.mktmpdir }
  let(:plain) do
    File.join(dir, 'in.pdf').tap do |path|
      File.binwrite(path, finance_pdf('Extrato teste 01/10/2026'))
    end
  end
  let(:encrypted) do
    File.join(dir, 'enc.pdf').tap do |path|
      system('qpdf', '--encrypt', 'senha', 'senha', '256', '--', plain, path, exception: true)
    end
  end

  before do
    missing = %w[qpdf pdftotext].reject { |bin| system('which', bin, out: File::NULL) }
    skip("install poppler-utils and qpdf to run (missing: #{missing.join(', ')})") if missing.any?
  end

  after { FileUtils.rm_rf(dir) }

  it 'extracts text' do
    expect(described_class.text(path: plain)).to include('Extrato teste')
  end

  it 'detects encryption' do
    expect(described_class.encrypted?(path: plain)).to be(false)
    expect(described_class.encrypted?(path: encrypted)).to be(true)
  end

  it 'extracts text with the password' do
    expect(described_class.text(path: encrypted, password: 'senha')).to include('Extrato teste')
  end

  it 'raises PasswordError with the wrong password' do
    expect { described_class.text(path: encrypted, password: 'errada') }
      .to raise_error(described_class::PasswordError)
  end

  it 'decrypts to a new file' do
    output = described_class.decrypt(path: encrypted, password: 'senha',
                                     output: File.join(dir, 'dec.pdf'))

    expect(described_class.encrypted?(path: output)).to be(false)
    expect(described_class.text(path: output)).to include('Extrato teste')
  end

  it 'raises PasswordError when decrypting with the wrong password' do
    output = File.join(dir, 'd.pdf')

    expect { described_class.decrypt(path: encrypted, password: 'x', output:) }
      .to raise_error(described_class::PasswordError)
  end

  it 'raises Error for a broken file' do
    broken = File.join(dir, 'broken.pdf').tap { |path| File.write(path, 'nope') }

    expect { described_class.text(path: broken) }.to raise_error(described_class::Error)
  end
end
