class CreateFilters < ActiveRecord::Migration[5.2]
  def up
    create_table :filters do |t|
      t.string :name

      t.timestamps
    end
  end

  def down
    drop_table :filters
  end
end
