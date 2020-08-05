class Seat < ApplicationRecord
  has_many :users, -> { where( :banned => false ) }
  has_many :hosts, :through => :users
  has_many :games, :through => :hosts
  has_many :identities, :through => :users

  scope :active, -> { joins(:users).merge(User.active) }

  require 'open-uri'
  require 'json'

  def as_json(options={})
   super(:only => [:seat, :section, :row, :number],
      :include => {
        :users => {:only => [:clan, :handle], :methods => [:playing],
          :include => {
            :host => {:only => [:url]},
            :identities => {:only => [:provider, :uid, :name, :url, :avatar]}
          }
        }
      }
    )
  end

  def Seat.update(info)
  	seat = Seat.where(seat: info["seat"]).first_or_create

  	seat.update_attributes(
  	  :clan   => info["clan"],
  	  :handle => info["handle"],
      :section => info["section"],
      :row => info["row"],
      :number => info["number"],
      :sort => info["sort"],
      :updated => true
  	)
  end

  def seat_clan_handle
    "#{seat} -- #{clan} #{handle}"[0..40]
  end

  def Seat.cleanup_seats
    puts "Filling in unavailable seats."
    
    s = Seat.distinct.pluck(:section)
    r = Seat.distinct.pluck(:row)
    n = Seat.distinct.pluck(:number)
    puts "Sections: #{s.count}"
    puts "Rows: #{r.count}"
    puts "Numbers: #{n.count}"

    i = 0
    s.each do |sec|
      r.each do |row|
        n.each do |num|
          seat = "#{sec}-#{row}-#{num}"
          current_seat = Seat.find_by(seat: seat)
          unless current_seat.present?

            if row.to_s.length == 2
              sort_letter = row.to_s
            else
              sort_letter = row.to_s.rjust(2, '0')
            end

            sort ="#{sec}#{sort_letter}#{sprintf '%02d', num.to_s}"

            i+=1
            puts "#{seat} #{sec} #{row} #{num} #{sort}"
            new_seat = Seat.where(seat: seat).first_or_create
          	new_seat.update_attributes(
          	  :clan   => nil,
          	  :handle => nil,
              :section => sec,
              :row => row,
              :number => num,
              :sort => sort,
              :updated => true
          	)
          end
        end
      end
    end
    puts "Processed #{i} seats"
  end

  def Seat.update_seats(file)
    if file == nil
      file = ENV["SEAT_API_URL"]
    end

    puts "File: #{file}"

    parsed = SteamWebApi.get_json(file)

    i = 0
    Seat.update_all(:updated => false)

    parsed["subChart"]["rows"].each do |row|
      row_letter = row["label"]
      row_letter .slice! "Row "
      row_letter.strip!

      row["seats"].each do |seat|
        section = seat["categoryLabel"]
        section.slice! "Section "
        section.strip!

        number = seat["label"]
        number.strip!

        seat = "#{section}-#{row_letter}-#{number}"
        clan = nil
        handle = nil

        if row_letter.length == 2
          sort_letter = row_letter
        else
          sort_letter = row_letter.rjust(2, '0')
        end
        sort ="#{section}#{sort_letter}#{sprintf '%02d', number}"

        info = { "seat"   => seat,
             "clan"   => clan,
             "handle" => handle,
             "section" => section,
             "row" => row_letter,
             "number" => number,
             "sort" => sort
             }

        line = ""
        info.each do |k,v|
          unless v.nil?
            line << "#{v} "
          end
        end
        puts line

        Seat.update(info)
        i+=1

      end
    end
    Seat.where(:updated => false).update_all(:handle => nil, :clan => nil)

    puts "Processed #{i} seats"
  end
end
