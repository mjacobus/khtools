# frozen_string_literal: true

class DateTimeParamParser
  def parse(params)
    params = params.stringify_keys
    extracted = extract_keys(params.keys)
    key_names(extracted).map do |name|
      [name.to_sym, try_parse(name, params)]
    end.to_h
  end

  private

  def extract_keys(keys)
    keys.map(&:to_s).select { |key| key.match?(/\([1-5]i\)$/) }.sort
  end

  def key_names(extracted)
    extracted.map { |key| key.split('(').first }.uniq
  end

  def try_parse(name, params)
    values = %w[1i 2i 3i 4i 5i].map do |suffix|
      key = "#{name}(#{suffix})"
      params[key]
    end

    if values.filter_map(&:presence).length < 5
      return nil
    end

    DateTime.new(*values.map(&:to_i))
  end
end
