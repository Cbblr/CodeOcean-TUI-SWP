# frozen_string_literal: true

require File.expand_path('../../lib/active_model/validations/boolean_presence_validator', __dir__)

class ExecutionEnvironment < ApplicationRecord
  include Creation
  include DefaultValues

  VALIDATION_COMMAND = 'whoami'
  RUNNER_MANAGEMENT_PRESENT = CodeOcean::Config.new(:code_ocean).read[:runner_management].present?
  BASE_URL = CodeOcean::Config.new(:code_ocean).read[:runner_management][:url] if RUNNER_MANAGEMENT_PRESENT
  HEADERS = {'Content-Type' => 'application/json'}.freeze
  DEFAULT_CPU_LIMIT = 20

  after_initialize :set_default_values

  has_many :exercises
  belongs_to :file_type
  has_many :error_templates

  scope :with_exercises, -> { where('id IN (SELECT execution_environment_id FROM exercises)') }

  validate :valid_test_setup?
  validate :working_docker_image?, if: :validate_docker_image?
  validates :docker_image, presence: true
  validates :memory_limit,
    numericality: {greater_than_or_equal_to: DockerClient::MINIMUM_MEMORY_LIMIT, only_integer: true}, presence: true
  validates :network_enabled, boolean_presence: true
  validates :name, presence: true
  validates :permitted_execution_time, numericality: {only_integer: true}, presence: true
  validates :pool_size, numericality: {only_integer: true}, presence: true
  validates :run_command, presence: true
  validates :cpu_limit, presence: true, numericality: {greater_than: 0, only_integer: true}
  validates :exposed_ports, format: {with: /\A(([[:digit:]]{1,5},)*([[:digit:]]{1,5}))?\z/}

  def set_default_values
    set_default_values_if_present(permitted_execution_time: 60, pool_size: 0)
  end
  private :set_default_values

  def to_s
    name
  end

  def copy_to_poseidon
    return false unless RUNNER_MANAGEMENT_PRESENT

    url = "#{BASE_URL}/execution-environments/#{id}"
    response = Faraday.put(url, to_json, HEADERS)
    return true if [201, 204].include? response.status

    Rails.logger.warn("Could not create execution environment in Poseidon, got response: #{response.as_json}")
    false
  end

  def to_json(*_args)
    {
      id: id,
      image: docker_image,
      prewarmingPoolSize: pool_size,
      cpuLimit: cpu_limit,
      memoryLimit: memory_limit,
      networkAccess: network_enabled,
      exposedPorts: exposed_ports_list,
    }.to_json
  end

  def exposed_ports_list
    (exposed_ports || '').split(',').map(&:to_i)
  end

  def valid_test_setup?
    if test_command? ^ testing_framework?
      errors.add(:test_command,
        I18n.t('activerecord.errors.messages.together',
          attribute: I18n.t('activerecord.attributes.execution_environment.testing_framework')))
    end
  end
  private :valid_test_setup?

  def validate_docker_image?
    docker_image.present? && !Rails.env.test?
  end
  private :validate_docker_image?

  def working_docker_image?
    DockerClient.pull(docker_image) if DockerClient.find_image_by_tag(docker_image).present?
    output = DockerClient.new(execution_environment: self).execute_arbitrary_command(VALIDATION_COMMAND)
    errors.add(:docker_image, "error: #{output[:stderr]}") if output[:stderr].present?
  rescue DockerClient::Error => e
    errors.add(:docker_image, "error: #{e}")
  end
  private :working_docker_image?
end
