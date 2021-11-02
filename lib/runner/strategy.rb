# frozen_string_literal: true

class Runner::Strategy
  def initialize(_runner_id, environment)
    @execution_environment = environment
  end

  def self.initialize_environment
    raise NotImplementedError
  end

  def self.sync_environment(_environment)
    raise NotImplementedError
  end

  def self.request_from_management(_environment)
    raise NotImplementedError
  end

  def destroy_at_management
    raise NotImplementedError
  end

  def copy_files(_files)
    raise NotImplementedError
  end

  def attach_to_execution(_command, _event_loop)
    raise NotImplementedError
  end

  def self.available_images
    raise NotImplementedError
  end

  def self.config
    raise NotImplementedError
  end

  def self.release
    raise NotImplementedError
  end

  def self.pool_size
    raise NotImplementedError
  end

  def self.websocket_header
    raise NotImplementedError
  end
end