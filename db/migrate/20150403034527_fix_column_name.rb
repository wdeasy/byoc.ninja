class FixColumnName < ActiveRecord::Migration
  def self.up
  	rename_column :servers, :override, :auto_update
  	change_column :servers, :auto_update, :boolean, :default => true
  	rename_column :users, :override, :auto_update
  	change_column :users, :auto_update, :boolean, :default => true

  	add_column :protocols, :host, :string, default: 'hostname'
  	add_column :protocols, :map, :string, default: 'map'
  	add_column :protocols, :num, :string, default: 'num_players'
  	add_column :protocols, :max, :string, default: 'max_players'
  	add_column :protocols, :pass, :string, default: 'password'

    add_column :groups, :enabled, :boolean, default: true
    add_column :users, :seat, :string

    create_table :seats, id: false do |t|
      t.string :seat, null: false
      t.string :clan
      t.string :handle
      t.boolean :updated, :default => true

      t.timestamps null: false 
    end

    add_index :seats, :seat, unique: true

    rename_column :users, :optout, :display
    change_column :users, :display, :boolean, :default => true
  end

  def self.down
  	rename_column :servers, :auto_update, :override
  	change_column :servers, :override, :boolean, :default => false
  	rename_column :users, :auto_update, :override
  	change_column :users, :override, :boolean, :default => false	

   	remove_column :protocols, :host
  	remove_column :protocols, :map
  	remove_column :protocols, :num
  	remove_column :protocols, :max
  	remove_column :protocols, :pass 

    remove_column :groups, :enabled
    remove_column :users, :seat 

    drop_table :seats
    remove_index :seats, :seat

    rename_column :users, :display, :optout
    change_column :users, :optout, :boolean, :default => false    	
  end
end
