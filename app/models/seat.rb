class Seat < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :hosts, :through => :users
  has_many :games, :through => :hosts

  #scope :current_year, -> (user) { includes(:users).where(year: Date.today.year, users: {user: user})}

  require 'open-uri'
  require 'json'

  def as_json(options={})
   super(:only => [:seat, :clan, :handle],
      :include => {
        :users => {:only => [:url],
          :include => {
            :host => {:only => [:link]},
            :game => {:only => [:name]}
          }
        }
      }
    )
  end

  def Seat.update(info)
  	seat = Seat.where(seat: info["seat"], year: info["year"]).first_or_create

  	seat.update_attributes(
  	  :clan   => info["clan"],
  	  :handle => info["handle"],
      :updated => true
  	)
  end

  def seat_clan_handle
    "#{seat} -- #{clan} #{handle}"[0..40]
  end

  def Seat.update_seats(file,year)
    if file == nil
      file = ENV["SEAT_API_URL"]
    end

    if year == nil
      year = Date.today.year
    end

    puts "File: #{file}"
    puts "Year: #{year}"

    begin
      parsed = JSON.parse(open(file).read)
    rescue => e
      return "JSON failed to parse #{file}"
    end

    i = 0
    Seat.where(:year => year).update_all(:updated => false)

    parsed.each do |obj|
      seat = nil
      clan = nil
      handle = nil

      seat = obj["objectLabelOrUuid"]
      a, b = seat.split('-')

      if a == "UAC"
        col = "UAC"
        row = ""
      else
        col = a[0]
        a[0] = ''
        row = "%02d" % a.to_i
      end
      num = "%02d" % b.to_i

      seat = "#{col}#{row}-#{num}"

      if obj["status"] == "booked"
        if obj["extraData"]
          if obj["extraData"]["alias"]
            handle = obj["extraData"]["alias"]
          else
            handle = "Reserved"
          end
          if obj["extraData"]["clan"]
            clan = obj["extraData"]["clan"]
          end
        end
      end

      info = { "seat"   => seat,
           "clan"   => clan,
           "handle" => handle,
           "year" => year
           }

      #puts "#{info['seat']} #{info['clan']} #{info['handle']}"

      line = "#{info['seat']}"
      if info['clan']
        line << " #{info['clan']}"
      end
      if info['handle']
        line << " #{info['handle']}"
      end
      puts line

      Seat.update(info)
      i+=1
    end
    Seat.where(:updated => false, :year => year).update_all(:handle => nil, :clan => nil)

    puts "Processed #{i} seats"
  end
end
