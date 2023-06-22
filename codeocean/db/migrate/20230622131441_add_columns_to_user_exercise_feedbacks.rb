class AddColumnsToUserExerciseFeedbacks < ActiveRecord::Migration[7.0]
  def change
    add_column :user_exercise_feedbacks, :user_error_feedback, :integer
    add_column :user_exercise_feedbacks, :user_error_feedback_text, :string
  end
end
