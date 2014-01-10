class AddDefaultToCommentPoints < ActiveRecord::Migration
  def change
    change_column :comments, :points, :integer, :default => 0
  end
end
