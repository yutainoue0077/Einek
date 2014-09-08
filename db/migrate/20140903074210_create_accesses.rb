class CreateAccesses < ActiveRecord::Migration
  def change
    create_table :accesses do |t|
      t.string :hall_name
      t.string :spot
      t.string :train

      t.timestamps
    end
  end
end
