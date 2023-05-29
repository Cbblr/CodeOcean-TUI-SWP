# frozen_string_literal: true

class JunitAdapter < TestingFrameworkAdapter
  COUNT_REGEXP = /Tests run: (\d+)/
  FAILURES_REGEXP = /Failures: (\d+)/
  SUCCESS_REGEXP = /OK \((\d+) tests?\)\s*(?:\x1B\]0;|exit)?\s*\z/
  ASSERTION_ERROR_REGEXP = /java\.lang\.AssertionError:?\s(.*?)\tat org\.junit|org\.junit\.ComparisonFailure:\s(.*?)\tat org\.junit|\)\r\n(.*?)\tat org\.junit\.internal\.ComparisonCriteria\.arrayEquals\(ComparisonCriteria\.java:50\)/m
  COMPILE_ERROR_REGEXP = /(.*).java:(\d*):\serror:\s(unclosed string literal|illegal start of expression|
  variable(?:.*) might not have been initialized|not a statement|(?:.+)expected|cannot find symbol|
  (?:.*) cannot be applied to (?:.*)|bad operand types (?:.*)|incompatible types:(?:.*)|missing return (?:.*)|
  invalid method declaration(?:.*)|unreachable statement|(?:.*) cannot be referenced from a static context)\s*^\s*(.*)/ 
  
  def self.framework_name
    'JUnit 4'
  end

  def parse_output(output)
    if SUCCESS_REGEXP.match(output[:stdout])
      {count: Regexp.last_match(1).to_i, passed: Regexp.last_match(1).to_i}
    else
      count = output[:stdout].scan(COUNT_REGEXP).try(:last).try(:first).try(:to_i) || 0
      failed = output[:stdout].scan(FAILURES_REGEXP).try(:last).try(:first).try(:to_i) || 0
      error_matches = output[:stdout].scan(ASSERTION_ERROR_REGEXP)
      File.write("Javaoutput.txt",output[:stderr])
      compile_error_matches = output[:stderr].scan(COMPILE_ERROR_REGEXP).map do |match|
        error_file=match[0]
        line_number=match[1]
        error_name=match[2].strip
        code=match[3].strip
        if error_file.downcase().include? "test"

        else
        "<span style=\"color:red\">**Compilation Error**</span> in **file** #{error_file} **line #{line_number}** occured **#{error_name}** at #{code} "
        end
      end || [] 
      File.write("JavaRegex.txt",compile_error_matches)
      
      {count:, failed:, error_messages: error_matches.flatten.compact_blank+compile_error_matches}
    end
  end
end
