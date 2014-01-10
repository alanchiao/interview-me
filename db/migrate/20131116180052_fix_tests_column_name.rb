class FixTestsColumnName < ActiveRecord::Migration
  def change
  	rename_column :tests, :probleim_id, :problem_id
  end
end
