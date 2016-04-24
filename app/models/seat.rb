class Seat < ActiveRecord::Base
  has_and_belongs_to_many :users

  #scope :current_year, -> (user) { includes(:users).where(year: Date.today.year, users: {user: user})}

  require 'open-uri'
  require 'json'

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
      file = "https://app.seats.io/api/event/3a0fe5eb-64c2-4dc4-88a1-c1d61e25e066/live-2016/objects/statuses"
    end

    if year == nil
      year = Date.today.year
    end

    puts "file: #{file}"
    puts "year: #{year}"

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

      puts "#{info['seat']} #{info['clan']} #{info['handle']}"
      Seat.update(info)
      i+=1
    end
    Seat.where(:updated => false, :year => year).update_all(:handle => nil, :clan => nil)

    return "processed #{i} seats."  
  end
end