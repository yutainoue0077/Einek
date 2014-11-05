class CreateAccesses < ActiveRecord::Migration
  def change
    create_table :accesses do |t|
      t.integer :hall_name
      t.integer :spot
      t.string :train

      t.timestamps
    end
  end
end
