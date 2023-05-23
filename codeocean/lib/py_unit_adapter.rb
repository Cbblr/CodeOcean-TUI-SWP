# frozen_string_literal: true

class PyUnitAdapter < TestingFrameworkAdapter
  COUNT_REGEXP = /Ran (\d+) test/
  FAILURES_REGEXP = /FAILED \(.*failures=(\d+).*\)/
  ERRORS_REGEXP = /FAILED \(.*errors=(\d+).*\)/
  ASSERTION_ERROR_REGEXP = /^(ERROR|FAIL):\ (.*?)\ .*?^[^.\n]*?(Error|Exception):\s((\s|\S)*?)(>>>[^>]*?)*\s\s(-|=){70}/m
  #regex to catch bad errors hindering code execution
  BAD_ERROR_REGEXP = /(SyntaxError|IndentationError|TabError):(.*)/
  FILE_LINE_SCAN = /File\s\"(.*)\"(?:.*)line\s(\d+)\s/
  #File\s\"(.*)\"(?:.*)line\s(\d+)\n(?:.*)\s*(?:\^*)\n(SyntaxError|IndentationError|TabError):(.*)

  def self.framework_name
    'PyUnit'
  end

  def parse_output(output)
    File.write("outputtest.txt",output[:stderr])
    # PyUnit is expected to print test results on Stderr!
    count = output[:stderr].scan(COUNT_REGEXP).try(:last).try(:first).try(:to_i) || 0
    failed = output[:stderr].scan(FAILURES_REGEXP).try(:last).try(:first).try(:to_i) || 0
    errors = output[:stderr].scan(ERRORS_REGEXP).try(:last).try(:first).try(:to_i) || 0
    begin
      assertion_error_matches = Timeout.timeout(2.seconds) do
        output[:stderr].scan(ASSERTION_ERROR_REGEXP).map do |match|
          testname = match[1]
          error = match[3].strip

          if testname == 'test_assess'
            error
          else
            "#{testname}: #{error}"
          end
        end || []
      end
    rescue Timeout::Error
      Sentry.capture_message({stderr: output[:stderr], regex: ASSERTION_ERROR_REGEXP}.to_json)
      assertion_error_matches = []
    end
    #catch bad errors here
    begin
      bad_error_matches = Timeout.timeout(2.seconds) do
        output[:stderr].scan(BAD_ERROR_REGEXP).map do |match|
          #example for a match ["SyntaxError", "invalid syntax"]
          error_name=match[0]
          error_message=match[1].strip
          "<span style=\"color:red\">**#{error_name}**</span>: #{error_message}"
        end || []
      end
    rescue Timeout::Error
      Sentry.capture_message({stderr: output[:stderr], regex: BAD_ERROR_REGEXP}.to_json)
      bad_error_matches = []
    end
    begin
      line_matches = Timeout.timeout(2.seconds) do
        output[:stderr].scan(FILE_LINE_SCAN).map do |match|
          #matches last file and line
          file_name=match[0]
          line_number=match[1].strip
          " in #{file_name} **line #{line_number}**"
        end || []
      end
    rescue Timeout::Error
      Sentry.capture_message({stderr: output[:stderr], regex: FILE_LINE_SCAN}.to_json)
      line_matches = []
    end
    if line_matches.length()==bad_error_matches.length()
      i=0
      while i<bad_error_matches.length() do
        bad_error_matches[i]=bad_error_matches[i]+line_matches[i]
        i=i+1
      end
    end
    #test files
    File.write("RegExTest.txt",bad_error_matches)
    File.write("comparison.txt",assertion_error_matches.flatten.compact_blank)
    #add bad errors to normal error array
    assertion_error_matches=assertion_error_matches+bad_error_matches
    {count:, failed: failed + errors, error_messages: assertion_error_matches.flatten.compact_blank}
  end
end
