class Seat < ApplicationRecord
  has_and_belongs_to_many :users
  has_many :hosts, :through => :users
  has_many :games, :through => :hosts

  #scope :current_year, -> (user) { includes(:users).where(year: Date.today.year, users: {user: user})}

  require 'open-uri'
  require 'json'

  def as_json(options={})
   super(:only => [:seat, :section, :row, :number],
      :include => {
        :users => {:only => [:url, :name], :methods => [:clan, :handle, :playing],
          :include => {
            :host => {:only => [:link]}
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

  def Seat.update_seats(file,year)
    if file == nil
      file = ENV["SEAT_API_URL"]
    end

    if year == nil
      year = Date.today.year
    end

    puts "File: #{file}"
    puts "Year: #{year}"

    parsed = Host.get_json(file)

    i = 0
    Seat.where(:year => year).update_all(:updated => false)

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
             "year" => year,
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
    Seat.where(:updated => false, :year => year).update_all(:handle => nil, :clan => nil)

    puts "Processed #{i} seats"
  end
end
