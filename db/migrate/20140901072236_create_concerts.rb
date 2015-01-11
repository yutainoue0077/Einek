class CreateConcerts < ActiveRecord::Migration
  def change
    create_table :concerts do |t|
      t.text  :name
      t.text  :program
      t.string  :stage

      t.integer :year
      t.integer :month
      t.integer :day

      t.string  :map
      t.string  :address
      t.string  :information
      t.integer :page_month

      t.string  :station

      t.timestamps
    end
  end
end
