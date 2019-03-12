module ActionCableHelper
  def trigger_rfc_action_cable
    # Context: RfC
    if submission.study_group_id.present?
      ActionCable.server.broadcast(
        "la_exercises_#{exercise_id}_channel_study_group_#{submission.study_group_id}",
        type: :rfc,
        id: id,
        html: (ApplicationController.render(partial: 'request_for_comments/list_entry',
                                            locals: {request_for_comment: self})))
    end
  end

  def trigger_rfc_action_cable_from_comment
    # Context: Comment
    RequestForComment.find_by(submission: file.context).trigger_rfc_action_cable
  end

  def trigger_working_times_action_cable
    # Context: Submission
    if study_group_id.present?
      ActionCable.server.broadcast(
          "la_exercises_#{exercise_id}_channel_study_group_#{study_group_id}",
          type: :working_times,
          working_time_data: exercise.get_working_times_for_study_group(study_group_id, user))
    end
  end
end

# TODO: Check if any user is connected and prevent preparing the data otherwise
