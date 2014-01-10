class RenameTypeColumns < ActiveRecord::Migration
  def change
    rename_column :problems, :type, :problem_type
    rename_column :users, :type, :usertype
  end
end
