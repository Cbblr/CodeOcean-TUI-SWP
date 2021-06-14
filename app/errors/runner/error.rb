# frozen_string_literal: true

class Runner
  class Error < ApplicationError
    class BadRequest < Error; end

    class EnvironmentNotFound < Error; end

    class ExecutionTimeout < Error; end

    class InternalServerError < Error; end

    class NotAvailable < Error; end

    class Unauthorized < Error; end

    class RunnerNotFound < Error; end

    class Unknown < Error; end
  end
end
