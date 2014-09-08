class CreateInfomations < ActiveRecord::Migration
  def change
    create_table :infomations do |t|
      t.string :oke_name
      t.string :info

      t.timestamps
    end
  end
end
