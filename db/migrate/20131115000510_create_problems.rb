class CreateProblems < ActiveRecord::Migration
  def change
    create_table :problems do |t|
      t.string :type
      t.string :title
      t.integer :difficulty
      t.text :question
      t.integer :category_id
      t.integer :author_id
      t.text :solution
      t.text :skeleton

      t.timestamps
    end
  end
end
