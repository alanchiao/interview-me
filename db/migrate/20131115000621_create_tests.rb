class CreateTests < ActiveRecord::Migration
  def change
    create_table :tests do |t|
      t.text :input
      t.integer :probleim_id
      t.string :correct_output

      t.timestamps
    end
  end
end
