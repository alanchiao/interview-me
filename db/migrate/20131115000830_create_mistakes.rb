class CreateMistakes < ActiveRecord::Migration
  def change
    create_table :mistakes do |t|
      t.integer :test_id
      t.string :wrong_output
      t.integer :hint_id

      t.timestamps
    end
  end
end
