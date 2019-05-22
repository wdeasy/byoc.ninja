class AddHostToUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :host, index: true
    add_foreign_key :users, :hosts

    add_reference :users, :seat, index: true
    add_foreign_key :users, :seats

    add_reference :hosts, :game, index: true
    add_foreign_key :hosts, :games

    add_reference :hosts, :network, index: true
    add_foreign_key :hosts, :networks, :default => 1
  end
end
