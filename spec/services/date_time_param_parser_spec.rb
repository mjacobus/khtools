# frozen_string_literal: true

RSpec.describe DateTimeParamParser do
  let(:input) do
    { 'assignee_id' => '136',
      'assigned_at(1i)' => '2023',
      'assigned_at(2i)' => '4',
      'assigned_at(3i)' => '17',
      'assigned_at(4i)' => '18',
      'assigned_at(5i)' => '45',
      'campaign_id' => '11',
      'returned_at(1i)' => '2023',
      'returned_at(2i)' => '5',
      'returned_at(3i)' => '18',
      'returned_at(4i)' => '19',
      'returned_at(5i)' => '50' }
  end
  let(:parsed) { described_class.new.parse(input) }

  it 'returns the formatted date times' do
    expected = {
      assigned_at: DateTime.parse('2023-04-17 18:45'),
      returned_at: DateTime.parse('2023-05-18 19:50')
    }
    expect(parsed).to eq(expected)
  end

  it 'returns nil if one of the numbers is nil' do
    input['assigned_at(1i)'] = ''

    expected = {
      assigned_at: nil,
      returned_at: DateTime.parse('2023-05-18 19:50')
    }
    expect(parsed).to eq(expected)
  end
end
