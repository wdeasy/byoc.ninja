namespace :cleanup do

  desc "Delete inactive hosts"
  task :hosts => :environment do
  	beginning = start_time
  	Host.where("updated_at < ? AND banned IS FALSE AND auto_update IS TRUE AND pin IS FALSE", 1.week.ago).delete_all
  	finish_time(beginning)
  end

  desc "Delete inactive pins"
  task :pins => :environment do
    beginning = start_time
    Host.cleanup_pins
    finish_time(beginning)
  end

  desc "Fills in missing information from early seat links"
  task :users => :environment do
    beginning = start_time
    users = User.where("url IS NULL")
    users.each do |user|
      puts "updating #{user.steamid}"
      User.fill(user.steamid)
    end

    finish_time(beginning)
  end

  desc "Clear out tables for a new year"
  task :tables => :environment do
    beginning = start_time
    hosts = Host.where(:visible => true)
    puts "Hiding #{hosts.count} hosts."
    hosts.update_all(:visible => false)
    users= User.where("admin = false")
    puts "Deleting #{users.count} users."
    users.delete_all
    puts "Deleting #{Seat.all.count} seats."
    Seat.destroy_all
    puts "Resetting User seat counts."
    User.update_all(:seat_count => 0);
    finish_time(beginning)
  end

  desc "Fill in missing seats"
  task :seats => :environment do
    beginning = start_time
    Seat.cleanup_seats
    finish_time(beginning)
  end

  def start_time
  	beginning = Time.now
  	puts beginning.to_formatted_s(:db)
  	return beginning
  end

  def finish_time(beginning)
  	puts "Time elapsed #{Time.now - beginning} seconds."
  end
end
