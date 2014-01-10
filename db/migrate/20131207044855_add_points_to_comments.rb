class AddPointsToComments < ActiveRecord::Migration
  def change
    add_column :comments, :points, :integer, after: :problem_id
  end
end
