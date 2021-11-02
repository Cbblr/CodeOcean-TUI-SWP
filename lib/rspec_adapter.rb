# frozen_string_literal: true

class RspecAdapter < TestingFrameworkAdapter
  REGEXP = /(\d+) examples?, (\d+) failures?/.freeze

  def self.framework_name
    'RSpec 3'
  end

  def parse_output(output)
    captures = output[:stdout].scan(REGEXP).try(:last).map(&:to_i)
    count = captures.first
    failed = captures.second
    {count: count, failed: failed}
  end
end
