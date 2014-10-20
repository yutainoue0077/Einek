class CreateConcerts < ActiveRecord::Migration
  def change
    create_table :concerts do |t|
      t.string :name
      t.string :program
      t.string :stage
      t.integer :month
      t.string :map
      t.string :address
      t.string :information
      t.integer :page_month
      t.integer :year

      t.timestamps
    end
  end
end
