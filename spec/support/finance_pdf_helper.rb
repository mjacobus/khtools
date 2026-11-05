# frozen_string_literal: true

# Builds a minimal one-page PDF with the given text lines, without external tools.
module FinancePdfHelper
  PDF_PAGE = '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] ' \
             '/Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>'
  PDF_FONT = '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>'

  def finance_pdf(*lines)
    shown = lines.map { |line| "(#{pdf_escape(line)}) '" }.join(' ')
    stream = "BT /F1 10 Tf 40 800 Td 12 TL #{shown} ET"
    objects = ['<< /Type /Catalog /Pages 2 0 R >>', '<< /Type /Pages /Kids [3 0 R] /Count 1 >>',
               PDF_PAGE, PDF_FONT, "<< /Length #{stream.bytesize} >>\nstream\n#{stream}\nendstream"]
    pdf_document(objects)
  end

  private

  def pdf_escape(text)
    text.encode('Windows-1252').force_encoding('BINARY').gsub(/[()\\]/) { |char| "\\#{char}" }
  end

  def pdf_document(objects)
    pdf = "%PDF-1.4\n".b
    offsets = objects.each_with_index.map do |object, index|
      pdf.bytesize.tap { pdf << "#{index + 1} 0 obj\n#{object}\nendobj\n".b }
    end
    pdf_trailer(pdf, offsets)
  end

  def pdf_trailer(pdf, offsets)
    xref = pdf.bytesize
    pdf << "xref\n0 #{offsets.size + 1}\n0000000000 65535 f \n"
    offsets.each { |offset| pdf << format("%010d 00000 n \n", offset) }
    pdf << "trailer\n<< /Size #{offsets.size + 1} /Root 1 0 R >>\nstartxref\n#{xref}\n%%EOF\n"
  end
end

RSpec.configure { |config| config.include FinancePdfHelper }
