class CreateAttempts < ActiveRecord::Migration
  def change
    create_table :attempts do |t|
      t.text :solution
      t.integer :user_id
      t.integer :problem_id

      t.timestamps
    end
  end
end
