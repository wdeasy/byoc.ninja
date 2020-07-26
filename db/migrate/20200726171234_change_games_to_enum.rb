class ChangeGamesToEnum < ActiveRecord::Migration[6.0]
  def up
    Game.where("source = 'auto'").update_all("source = '0'")
    Game.where("source = 'manual'").update_all("source = '1'")

    change_column :games, :source, :integer, using: 'source::integer'
  end

  def down
    change_column :games, :source, :string

    Game.where("source = '0'").update_all("source = 'auto'")
    Game.where("source = '1'").update_all("source = 'manual'")
  end
end
