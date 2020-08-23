namespace :update do

  desc "Queries host information from steam groups"
  task :hosts => :environment do
    beginning = start_time
    Host.update_hosts
    finish_time(beginning)
    system("touch /tmp/finished")
  end

  desc "Queries host information from steam groups"
  task :qconbyoc => :environment do
    beginning = start_time
    Identity.update_qconbyoc
    finish_time(beginning)
    system("touch /tmp/qconbyoc")
  end

  desc "Update byoc seat information args[file]"
  task :seats, [:file] => :environment do |t, args|
    beginning = start_time
    file = args.file
    Seat.update_seats(file)
    finish_time(beginning)
  end

  desc "Search byoc ip range for hosts"
  task :byoc => :environment do
    beginning = start_time
    Host.update_byoc
    finish_time(beginning)
    system("touch /tmp/byoc")
  end

  desc "Update pins"
  task :pins => :environment do
    beginning = start_time
    Host.update_pins
    finish_time(beginning)
  end

  desc "Update games"
  task :games => :environment do
    beginning = start_time
    Game.update_games
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
