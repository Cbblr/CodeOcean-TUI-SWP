class RenameUserExerciseFeedbackColumns < ActiveRecord::Migration[7.0]
  def change
    rename_column :user_exercise_feedbacks, :user_error_feedback_minutes, :user_estimated_worktime_minutes
    rename_column :user_exercise_feedbacks, :user_error_feedback_hours, :user_estimated_worktime_hours
  end
end
