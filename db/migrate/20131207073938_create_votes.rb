class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
        t.integer :user_id
        t.integer :comment_id
        t.boolean :upvote

        t.timestamps
    end
  end
end
