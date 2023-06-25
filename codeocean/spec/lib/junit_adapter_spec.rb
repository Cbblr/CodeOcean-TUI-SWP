# frozen_string_literal: true

require 'rails_helper'

describe JunitAdapter do
  let(:adapter) { described_class.new }

  describe '#parse_output' do
    
    context 'CorrectSolution' do
      #Initialize data for Testcase 2.1
      let(:count) { 42 }
      let(:stdout) { "OK (#{count} tests)" }
      
      #Testcase 2.1
      it 'returns the correct numbers' do
        expect(adapter.parse_output(stdout:)).to eq(count:, passed: count)
      end
    end

    context 'with assertionerrors' do
      #Initialize data for Testcase 2.2
      let(:count) { 42 }
      let(:failed) { 25 }
      let(:stdout) { "FAILURES!!!\nTests run: #{count},  Failures: #{failed}" }
      let(:error_matches) { [] }
      
      #Testcase 2.2
      it 'returns the correct numbers' do
        expect(adapter.parse_output(stdout:)).to eq(count:, failed:, error_messages: error_matches)
      end
    end

    context 'with CompilationErrors' do
      #count and failed always 0 for following test cases (tests can't be executed)
      let(:count) {0}
      let(:failed) {0}

      #Initialize data for Testcase 2.3
      let(:stderr) { File.read("spec/testcasedatajava/UnclosedStringLiteralTest.txt")}
      let(:error_matches) { File.read("spec/testcasedatajava/UnclosedStringLiteralTestErrors.txt")}

      #Testcase 2.3
      it 'unclosed string literal' do
        expect(adapter.parse_output(stderr:)).to eq(count:, failed:, error_messages: error_matches)
      end

      #Initialize data for Testcase 2.4
      let(:stderr) { File.read("spec/testcasedatajava/IllegalStartOfExpressionTest.txt")}
      let(:error_matches) {File.read("spec/testcasedatajava/IllegalStartOfExpressionTestErrors.txt")}

      #Testcase 2.4
      it 'illegal start of expression' do
        expect(adapter.parse_output(stderr:)).to eq(count:, failed:, error_messages: error_matches)
      end

      #Initialize data for Testcase 2.5
      let(:stderr) { File.read("spec/testcasedatajava/VariableMightNotHaveBeenInitializedTest.txt")}
      let(:error_matches) { File.read("spec/testcasedatajava/VariableMightNotHaveBeenInitializedTestErrors.txt")}

      #Testcase 2.5
      it 'variable .. might not have been initialized' do
        expect(adapter.parse_output(stderr:)).to eq(count:, failed:, error_messages: error_matches)
      end

      #Initialize data for Testcase 2.6
      let(:stderr) { File.read("spec/testcasedatajava/NotAStatementTest.txt")}
      let(:error_matches) { File.read("spec/testcasedatajava/NotAStatementTestErrors.txt")}

      #Testcase 2.6
      it 'not a statement' do
        expect(adapter.parse_output(stderr:)).to eq(count:, failed:, error_messages: error_matches)
      end

      #Initialize data for Testcase 2.7
      let(:stderr) { File.read("spec/testcasedatajava/UnexpectedTypeTest.txt")}
      let(:error_matches) { File.read("spec/testcasedatajava/UnexpectedTypeTestErrors.txt")}

      #Testcase 2.7
      it 'unexpected type' do
        expect(adapter.parse_output(stderr:)).to eq(count:, failed:, error_messages: error_matches)
      end

      #Initialize data for Testcase 2.8
      let(:stderr) { File.read("spec/testcasedatajava/SomethingExpectedTest.txt")}
      let(:error_matches) { File.read("spec/testcasedatajava/SomethingExpectedTestErrors.txt")}

      #Testcase 2.8
      it '... expected' do
        expect(adapter.parse_output(stderr:)).to eq(count:, failed:, error_messages: error_matches)
      end

      #Initialize data for Testcase 2.9
      let(:stderr) { File.read("spec/testcasedatajava/BadOperandTypesTest.txt")}
      let(:error_matches) { File.read("spec/testcasedatajava/BadOperandTypesTestErrors.txt")}

      #Testcase 2.9
      it 'bad operand types ...' do
        expect(adapter.parse_output(stderr:)).to eq(count:, failed:, error_messages: error_matches)
      end

      #Initialize data for Testcase 2.10
      let(:stderr) { File.read("spec/testcasedatajava/IncompatibleTypesTest.txt")}
      let(:error_matches) { File.read("spec/testcasedatajava/IncompatibleTypesTestErrors.txt")}

      #Testcase 2.10
      it 'incompatible types: ...' do
        expect(adapter.parse_output(stderr:)).to eq(count:, failed:, error_messages: error_matches)
      end

      #Initialize data for Testcase 2.11
      let(:stderr) { File.read("spec/testcasedatajava/MissingReturnTest.txt")}
      let(:error_matches) { File.read("spec/testcasedatajava/MissingReturnTestErrors.txt")}

      #Testcase 2.11
      it 'missing return ..' do
        expect(adapter.parse_output(stderr:)).to eq(count:, failed:, error_messages: error_matches)
      end

      #Initialize data for Testcase 2.12
      let(:stderr) { File.read("spec/testcasedatajava/InvalidMethodDeclarationTest.txt")}
      let(:error_matches) { File.read("spec/testcasedatajava/InvalidMethodDeclarationTestErrors.txt")}
 
      #Testcase 2.12
      it 'invalid method declaration ...' do
        expect(adapter.parse_output(stderr:)).to eq(count:, failed:, error_messages: error_matches)
      end

      #Initialize data for Testcase 2.13
      let(:stderr) { File.read("spec/testcasedatajava/UnreachableStatementTest.txt")}
      let(:error_matches) { File.read("spec/testcasedatajava/UnreachableStatementTestErrors.txt")}
 
      #Testcase 2.13
      it 'unreachable statement' do
        expect(adapter.parse_output(stderr:)).to eq(count:, failed:, error_messages: error_matches)
      end

      #Initialize data for Testcase 2.14
      let(:stderr) { File.read("spec/testcasedatajava/CannotBeReferencedFromAStaticContextTest.txt")}
      let(:error_matches) { File.read("spec/testcasedatajava/CannotBeReferencedFromAStaticContextTestErrors.txt")}
 
      #Testcase 2.14
      it '... cannot be referenced from a static context' do
        expect(adapter.parse_output(stderr:)).to eq(count:, failed:, error_messages: error_matches)
      end

      #Initialize data for Testcase 2.14
      let(:stderr) { File.read("spec/testcasedatajava/CannotBeReferencedFromAStaticContextTest.txt")}
      let(:error_matches) { File.read("spec/testcasedatajava/CannotBeReferencedFromAStaticContextTestErrors.txt")}
 
      #Testcase 2.14
      it '... cannot be referenced from a static context' do
        expect(adapter.parse_output(stderr:)).to eq(count:, failed:, error_messages: error_matches)
      end

      #Initialize data for Testcase 2.15
      let(:stderr) { File.read("spec/testcasedatajava/ReachedEndOfFileWhileParsingTest.txt")}
      let(:error_matches) { File.read("spec/testcasedatajava/ReachedEndOfFileWhileParsingTestErrors.txt")}
 
      #Testcase 2.15
      it 'reached end of file while parsing' do
        expect(adapter.parse_output(stderr:)).to eq(count:, failed:, error_messages: error_matches)
      end

      #Initialize data for Testcase 2.16
      let(:stderr) { File.read("spec/testcasedatajava/CannotBeAppliedToTest.txt")}
      let(:error_matches) { File.read("spec/testcasedatajava/CannotBeAppliedToTestErrors.txt")}

      #Testcase 2.16
      it '... cannot be applied to ...' do
        expect(adapter.parse_output(stderr:)).to eq(count:, failed:, error_messages: error_matches)
      end

      #Initialize data for Testcase 2.17
      let(:stderr) { File.read("spec/testcasedatajava/CannotFindSymbolTest.txt")}
      let(:error_matches) { File.read("spec/testcasedatajava/CannotFindSymbolTestErrors.txt")}

      #Testcase 2.17
      it 'cannot find symbol...' do
        expect(adapter.parse_output(stderr:)).to eq(count:, failed:, error_messages: error_matches)
      end
    end

  end
end
