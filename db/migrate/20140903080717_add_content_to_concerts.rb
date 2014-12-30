class AddContentToConcerts < ActiveRecord::Migration
  def change
    add_column :concerts, :content, :text
  end
end
