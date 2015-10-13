class Seat < ActiveRecord::Base
  self.primary_key = :seat
  has_many :users, :foreign_key => :seat

  require 'open-uri'
  require 'json'
  require 'matrix'  

  def Seat.update(info)
  	seat = Seat.where(seat: info["seat"]).first_or_create

  	seat.update_attributes(
  	  :clan   => info["clan"],
  	  :handle => info["handle"],
      :updated => true
  	)
  end

  def seat_clan_handle
  	"#{seat} -- #{clan} #{handle}"
  end

  def Seat.update_seats
    string = "https://registration.quakecon.org/?action=byoc_data&response_type=json"

    begin
      parsed = JSON.parse(open(string).read)
    rescue => e
      return "JSON failed to parse #{string}"
    end

    seats = parsed["data"]["seats"]
    tags = parsed["data"]["tags"]

    b62 = Radix::Base.new(('A'..'Z').to_a + ('a'..'z').to_a + ('0'..'9').to_a)
    b10 = Radix::Base.new(Radix::BASE::B10)

    i = 0
    j = 0
    colA = Matrix.build(74,10) {|row, col| i += 1 }
    colB = Matrix.build(74,22) {|row, col| i += 1 }
    colC = Matrix.build(64,12) {|row, col| i += 1 }
    colU = Matrix.build(12,10) {|row, col| i += 1 }

    Seat.update_all(:updated => false)

    seats.each do |seat|

      seatLoc = ''

      seatNum = b10.convert(seat[0], b62).to_i + 1

      if colA.index(seatNum) != nil
        seatLoc << 'A' + sprintf('%02d',((colA.index(seatNum)[0]) + 1)) + '-' + sprintf('%02d',((colA.index(seatNum)[1]) + 1))
      elsif colB.index(seatNum) != nil
        seatLoc << 'B' + sprintf('%02d',((colB.index(seatNum)[0]) + 1)) + '-' + sprintf('%02d',((colB.index(seatNum)[1]) + 1))
      elsif colC.index(seatNum) != nil
        seatLoc << 'C' + sprintf('%02d',((colC.index(seatNum)[0]) + 1)) + '-' + sprintf('%02d',((colC.index(seatNum)[1]) + 1))
      elsif colU.index(seatNum) != nil
        num = seatNum - 3137
        table = (num/10).floor + 1
        row = (num%10).floor + 1

        digit = 13 - table + (10 - row)

        if row == 1
          digit += 2 * (table - 1)
        end

        seatLoc << 'UAC-' + sprintf('%02d', digit)
      end

      if seat[1][0] == ":"
        clan = ''
      else
        clanSplit = seat[1].split(":",2)
        clan = tags[clanSplit[0]]
      end

      if seat[1][-1,1] == ":"
        handle = 'Reserved'
      else
        handleSplit = seat[1].split(":",2)
        handle = handleSplit[1]
      end

      info = { "seat"   => seatLoc,
           "clan"   => clan,
           "handle" => handle
           }

      Seat.update(info)
      j+=1
    end
    Seat.where(:updated => false).update_all(:handle => nil, :clan => nil)
    return "processed #{j} seats."  
  end
end