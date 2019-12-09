# frozen_string_literal: true

require 'mimemagic'

module ProformaService
  class ConvertExerciseToTask < ServiceBase
    DEFAULT_LANGUAGE = 'de'

    def initialize(exercise: nil)
      @exercise = exercise
    end

    def execute
      create_task
    end

    private

    def create_task
      Proforma::Task.new(
        {
          title: @exercise.title,
          description: @exercise.description,
          internal_description: @exercise.instructions,
          files: task_files,
          tests: tests,
          uuid: uuid,
          language: DEFAULT_LANGUAGE,
          model_solutions: model_solutions,
          import_checksum: @exercise.import_checksum
        }.compact
      )
    end

    def uuid
      @exercise.update(uuid: SecureRandom.uuid) if @exercise.uuid.nil?
      @exercise.uuid
    end

    def model_solutions
      @exercise.files.filter { |file| file.role == 'reference_implementation' }.map do |file|
        Proforma::ModelSolution.new(
          id: "ms-#{file.id}",
          files: model_solution_file(file)
        )
      end
    end

    def model_solution_file(file)
      [
        task_file(file).tap do |ms_file|
          ms_file.used_by_grader = false
          ms_file.usage_by_lms = 'display'
          ms_file.visible = 'delayed'
        end
      ]
    end

    def tests
      @exercise.files.filter { |file| file.role == 'teacher_defined_test' }.map do |file|
        Proforma::Test.new(
          id: file.id,
          title: file.name,
          files: test_file(file),
          meta_data: {
            'feedback-message' => file.feedback_message
          }.compact
        )
      end
    end

    def test_file(file)
      [
        task_file(file).tap do |t_file|
          t_file.used_by_grader = true
          t_file.internal_description = 'teacher_defined_test'
        end
      ]
    end

    def task_files
      @exercise.files
               .filter { |file| !file.role.in? %w[reference_implementation teacher_defined_test] }.map do |file|
        task_file(file)
      end
    end

    def task_file(file)
      Proforma::TaskFile.new(
        {
          id: file.id,
          filename: file.path.present? && file.path != '.' ? ::File.join(file.path, file.name_with_extension) : file.name_with_extension,
          usage_by_lms: file.read_only ? 'display' : 'edit',
          visible: file.hidden ? 'no' : 'yes',
          internal_description: file.role || 'regular_file'
        }.tap do |params|
          if file.native_file.present?
            file = ::File.new(file.native_file.file.path, 'r')
            params[:content] = file.read
            params[:used_by_grader] = false
            params[:binary] = true
            params[:mimetype] = MimeMagic.by_magic(file).type
          else
            params[:content] = file.content
            params[:used_by_grader] = true
            params[:binary] = false
          end
        end
      )
    end
  end
end
