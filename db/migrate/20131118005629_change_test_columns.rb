class ChangeTestColumns < ActiveRecord::Migration
  def change
    rename_column :tests, :problem_id, :code_problem_id

  end
end
