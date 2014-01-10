class ChangeCommentProblemId < ActiveRecord::Migration
  def change
    rename_column :comments, :problem_id, :design_problem_id
  end
end
