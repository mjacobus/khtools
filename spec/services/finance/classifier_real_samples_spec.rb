# frozen_string_literal: true

require 'rails_helper'

# Opt-in check against real documents kept outside this public repository:
#   FINANCE_SAMPLES_DIR=/path/to/samples \
#     bin/rspec spec/services/finance/classifier_real_samples_spec.rb
# The directory holds the files plus a manifest.yml list of
# {file, kind, date, amount_cents, period}.
RSpec.describe Finance::Classifier, :real_samples do
  dir = ENV.fetch('FINANCE_SAMPLES_DIR', nil)

  if dir.blank?
    it('runs only with FINANCE_SAMPLES_DIR') { skip 'set FINANCE_SAMPLES_DIR to run' }
  else
    # Drive exports may store accented names decomposed (NFD); match them normalized.
    files = Dir.glob(File.join(dir, '**/*')).index_by(&:unicode_normalize)

    YAML.safe_load_file(File.join(dir, 'manifest.yml'), permitted_classes: [Date]).each do |sample|
      it "classifies #{sample['file']}" do
        path = files.fetch(File.join(dir, sample['file']).unicode_normalize)
        result = described_class.call(text: Finance::Pdf.text(path:), filename: File.basename(path))

        expected = { kind: sample['kind'], document_date: sample['date'],
                     amount_cents: sample['amount_cents'], period: sample['period'] }.compact
        expect(result).to have_attributes(expected)
      end
    end
  end
end
