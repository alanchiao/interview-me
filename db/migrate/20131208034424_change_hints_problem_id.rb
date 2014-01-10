class ChangeHintsProblemId < ActiveRecord::Migration
  def change
  	rename_column :hints, :problem_id, :code_problem_id
  end
end
