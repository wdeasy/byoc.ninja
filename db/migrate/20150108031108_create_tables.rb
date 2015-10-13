class CreateTables < ActiveRecord::Migration
  def change

    create_table :servers, id: false do |t|
      t.string :gameserverip, null: false
      t.string :ip
      t.integer :port
      t.integer :query_port
      t.string :gameid
      t.string :name      
      t.string :map
      t.integer :current
      t.integer :max
      t.boolean :password
      t.integer :users_count
      t.string :network, :default => 'wan'
      t.boolean :respond, :default => true
      t.boolean :override, :default => false
      t.boolean :banned, :default => false      
      t.boolean :updated, :default => false
      t.boolean :visible, :default => false
      t.boolean :refresh, :default => false
      t.string :slug

      t.timestamps null: false
    end

    add_index :servers, :gameserverip, unique: true

    create_table :users, id: false do |u|
      u.integer :steamid, :limit => 8, null: false
      u.string :personaname
      u.string :profileurl
      u.string :avatar
      u.string :gameserverip
      u.integer :lobbysteamid, :limit => 8
      u.boolean :admin, :default => false
      u.boolean :override, :default => false
      u.boolean :optout, :default => false
      u.boolean :banned, :default => false
      u.boolean :updated, :default => false      

      u.timestamps null: false
    end

    add_index :users, :steamid, unique: true

    create_table :groups, id: false do |w|
      w.integer :groupid64, :limit => 8, null: false
      w.string :name
      w.string :url

      w.timestamps null: false      
    end

    add_index :groups, :groupid64, unique: true

    create_table :games, id: false do |y|
      y.string :gameid, null: false
      y.string :gameextrainfo
      y.integer :query_port
      y.string :protocol, :default => nil

      y.timestamps null: false      
    end

    add_index :games, :gameid, unique: true

    create_table :lobbies, id: false do |z|
      z.integer :lobbysteamid, :limit => 8, null: false
      z.string  :gameserverip
      z.boolean :updated, :default => false

      z.timestamps null: false
    end

    add_index :lobbies, :lobbysteamid, unique: true

    create_table :networks do |a|
      a.string :network
      a.string :min      
      a.string :max

      a.timestamps null: false
    end

    create_table :protocols do |b|
      b.string :protocol
      b.string :name, unique: true     

      b.timestamps null: false
    end

    add_index :protocols, :protocol, unique: true

    create_table :messages do |c|
      c.string :message
      c.string :message_type
      c.boolean :show, default: true

      c.timestamps null: false
    end
  end
end
