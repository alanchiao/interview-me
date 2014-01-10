class ChangeUsersUsertype < ActiveRecord::Migration
  def change
  	change_column :users, :usertype, :string
  end
end
