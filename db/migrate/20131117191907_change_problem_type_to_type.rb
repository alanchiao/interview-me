class ChangeProblemTypeToType < ActiveRecord::Migration
  def change
	rename_column :problems, :problem_type, :type
  end
end
