# frozen_string_literal: true

require 'rails_helper'

# All texts are invented; they only follow the shape of the real documents.
RSpec.describe Finance::Classifier do
  def classify(text)
    described_class.new.classify(text:)
  end

  it 'reads an S-30 period' do
    text = "RELATÓRIO MENSAL DE CONTAS DA CONGREGAÇÃO (S-30)\nFolha de Contas (S-26)\n" \
           "Congregação Exemplo (12345) agosto de 2026\nSaldo 1.000,00"

    expect(classify(text)).to have_attributes(kind: 's30', period: '2026-08', amount_cents: nil)
  end

  it 'reads an S-26 period' do
    text = "FOLHA DE CONTAS (S-26)\n" \
           "Congregação Exemplo (12345) setembro de 2026\n01 Obra mundial O 10,00"

    expect(classify(text)).to have_attributes(kind: 's26', period: '2026-09')
  end

  it 'recognizes an audit report' do
    text = "RELATÓRIO DE AUDITORIA DAS CONTAS DA CONGREGAÇÃO (S-25)\n" \
           'Período: junho a agosto de 2026'

    expect(classify(text)).to have_attributes(kind: 'audit_report', period: '2026-08')
  end

  it 'reads a remittance record' do
    text = "Transações\nRemessas\nDonativos Valor\nObra mundial 787,05\nTotal R$1.587,05\n" \
           "Data do depósito\n2 de novembro de 2026\nNúmero de confirmação: 1234567"

    expect(classify(text)).to have_attributes(kind: 'remittance_record',
                                              document_date: Date.new(2026, 11, 2),
                                              amount_cents: 158_705)
  end

  it 'reads a remittance receipt (Pix to ATV)' do
    text = "Comprovante de transação Pix\nTransferência\nData da operação: 02/11/2026 - 10:00\n" \
           "Dados do recebedor\nNome: ASSOCIACAO EXEMPLO\nCPF/CNPJ: 33.755.687/0001-24\n" \
           "Dados do pagamento\nValor: 1,587.05\nData: 02/11/2026"

    expect(classify(text)).to have_attributes(kind: 'remittance_receipt',
                                              document_date: Date.new(2026, 11, 2),
                                              amount_cents: 158_705)
  end

  it 'recognizes a thank-you letter' do
    text = "(12345) Congregação Exemplo Setembro 2026\nCarta de Agradecimento\n" \
           "Agradecemos por seu apoio à obra mundial.\n" \
           '09/09/2026 Donativos (Obra Mundial) 10,00 BRL'

    expect(classify(text)).to have_attributes(kind: 'thank_you_letter', period: '2026-09')
  end

  it 'reads a bank statement period' do
    text = "Extrato de Conta Corrente\nData: 03/11/2026 - 10h00\n" \
           "Movimentação entre: 01/10/2026 e 31/10/2026\n" \
           "Data Histórico Crédito Débito Saldo\n30/09/2026 Saldo Anterior R$ 1.000,00"

    expect(classify(text)).to have_attributes(kind: 'statement', period: '2026-10')
  end

  it 'files a statement under the last complete month it covers' do
    text = "Extrato\nPeríodo: 30/09/2026 a 03/11/2026\n30/09/2026 Saldo Anterior\n" \
           "15/10/2026 Pix recebido\n03/11/2026 Saldo do dia"

    expect(classify(text)).to have_attributes(kind: 'statement', period: '2026-10')
  end

  it 'files a statement ending on the last day of a month under that month' do
    text = "Extrato\n30/09/2026 Saldo Anterior\n31/10/2026 Saldo final"

    expect(classify(text)).to have_attributes(kind: 'statement', period: '2026-10')
  end

  it 'reads a Pix payment receipt with the payee, not the payer' do
    text = "Comprovante de transação Pix\nPagamento\nData da operação: 26/10/2026 20:20:32\n" \
           "Dados do pagador\nNome: FULANO PAGADOR\nDados do recebedor\n" \
           "Nome: ENERGIA EXEMPLO DISTRIBUIDORA S.A\nDados do pagamento\n" \
           "Valor: 104.33\nData: 26/10/2026"

    expect(classify(text)).to have_attributes(kind: 'payment_receipt',
                                              document_date: Date.new(2026, 10, 26),
                                              amount_cents: 10_433,
                                              description: 'Energia Exemplo')
  end

  it 'reads a bill: amount repeated, due date on the same line' do
    text = "DOCUMENTO AUXILIAR DE NOTA FISCAL\nAGUA EXEMPLO SA\nEMISSÃO 21/08/2026\n" \
           "VALOR AGUA 64,05\nTOTAL 152,24\n" \
           "REFERÊNCIA VENCIMENTO TOTAL (R$)\n08/2026 10/09/2026 R$ 152,24"

    expect(classify(text)).to have_attributes(kind: 'bill', document_date: Date.new(2026, 9, 10),
                                              amount_cents: 15_224, description: 'Agua')
  end

  it 'reads an NF-e: due date after Venc.' do
    text = "RECEBEMOS DE EXEMPLO EMBALAGENS LTDA OS PRODUTOS CONSTANTES DA NOTA FISCAL\nNF-e\n" \
           "EMISSÃO: 18/09/2026 VALOR TOTAL: R$ 171,26\nFATURA / DUPLICATA\n" \
           "Venc. 25/09/2026\nValor R$ 171,26"

    expect(classify(text)).to have_attributes(kind: 'bill', document_date: Date.new(2026, 9, 25),
                                              amount_cents: 17_126, description: 'Exemplo')
  end

  it 'reads a TO-62 from the Hub as a remittance record' do
    text = "REGISTRO DE TRANSFERÊNCIA DE FUNDOS (TO-62)\nObra mundial (resolução) 800,00\n" \
           "TOTAL DE FUNDOS ENVIADOS: 1.578,50\n31 de julho de 2026 1234567\n" \
           'Data da movimentação Número de confirmação'

    expect(classify(text)).to have_attributes(kind: 'remittance_record',
                                              document_date: Date.new(2026, 7, 31),
                                              amount_cents: 157_850)
  end

  it 'reads a bill total printed below its header, even in US format' do
    text = "AGUA EXEMPLO SA\nPIS 74,49 1,650% 1,22\nHISTÓRICO 77,90 PAGA\nHISTÓRICO 77,90 PAGA\n" \
           "REFERÊNCIA VENCIMENTO TOTAL (R$)\n10/2026 10/11/2026 R$ 105.59\nEMISSÃO 26/10/2026"

    expect(classify(text)).to have_attributes(kind: 'bill', document_date: Date.new(2026, 11, 10),
                                              amount_cents: 10_559)
  end

  it 'reads columned NF-e totals and due dates' do
    text = "NF-e\nVALOR DO ICMS VALOR TOTAL DOS PRODUTOS\n 0,00 230,00\n" \
           "DESCONTO OUTRAS DESPESAS VALOR TOTAL DA NOTA\n 10,00 0,00 220,00\n" \
           "MATRÍCULA REFERÊNCIA EMISSÃO VENCIMENTO\n123 Jul/2026 21/07/2026 1 10/08/2026"

    expect(classify(text)).to have_attributes(kind: 'bill', document_date: Date.new(2026, 8, 10),
                                              amount_cents: 22_000)
  end

  it 'keeps a boleto with a delivery receipt as a bill' do
    text = "NF-e\nComprovante de Entrega\n" \
           "Local de Pagamento Vencimento\nPAGÁVEL EM QUALQUER BANCO 24/10/2026\n" \
           'Valor R$ 396,11'

    expect(classify(text)).to have_attributes(kind: 'bill', amount_cents: 39_611)
  end

  it 'returns unknown for anything else' do
    expect(classify('lorem ipsum 12/12/2026')).to have_attributes(kind: 'unknown')
  end
end
