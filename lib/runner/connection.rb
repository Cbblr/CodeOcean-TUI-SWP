# frozen_string_literal: true

require 'faye/websocket/client'
require 'json_schemer'

class Runner::Connection
  # These are events for which callbacks can be registered.
  EVENTS = %i[start output exit stdout stderr].freeze
  BACKEND_OUTPUT_SCHEMA = JSONSchemer.schema(JSON.parse(File.read('lib/runner/backend-output.schema.json')))

  attr_writer :status

  def initialize(url, strategy)
    @socket = Faye::WebSocket::Client.new(url, [], ping: 5)
    @strategy = strategy
    @status = :established

    # For every event type of faye websockets, the corresponding
    # RunnerConnection method starting with `on_` is called.
    %i[open message error close].each do |event_type|
      @socket.on(event_type) {|event| __send__(:"on_#{event_type}", event) }
    end

    # This registers empty default callbacks.
    EVENTS.each {|event_type| instance_variable_set(:"@#{event_type}_callback", ->(e) {}) }
    @start_callback = -> {}
    # Fail if no exit status was returned.
    @exit_code = 1
  end

  def on(event, &block)
    return unless EVENTS.include? event

    instance_variable_set(:"@#{event}_callback", block)
  end

  def send(data)
    @socket.send(encode(data))
  end

  private

  def decode(_raw_event)
    raise NotImplementedError
  end

  def encode(_data)
    raise NotImplementedError
  end

  def on_message(raw_event)
    event = decode(raw_event)
    return unless BACKEND_OUTPUT_SCHEMA.valid?(event)

    event = event.deep_symbolize_keys
    # There is one `handle_` method for every message type defined in the WebSocket schema.
    __send__("handle_#{event[:type]}", event)
  end

  def on_open(_event)
    @start_callback.call
  end

  def on_error(_event); end

  def on_close(_event)
    case @status
      when :timeout
        raise Runner::Error::ExecutionTimeout.new('Execution exceeded its time limit')
      when :terminated
        @exit_callback.call @exit_code
      else # :established
        # If the runner is killed by the DockerContainerPool after the maximum allowed time per user and
        # while the owning user is running an execution, the command execution stops and log output is incomplete.
        raise Runner::Error::Unknown.new('Execution terminated with an unknown reason')
    end
  end

  def handle_exit(event)
    @status = :terminated
    @exit_code = event[:data]
  end

  def handle_stdout(event)
    @stdout_callback.call event[:data]
    @output_callback.call event[:data]
  end

  def handle_stderr(event)
    @stderr_callback.call event[:data]
    @output_callback.call event[:data]
  end

  def handle_error(_event); end

  def handle_start(_event); end

  def handle_timeout(_event)
    @status = :timeout
  end
end
