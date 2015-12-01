namespace :update do

  desc "Queries host information from steam groups"
  task :hosts => :environment do
  	beginning = start_time
  	puts Host.update_hosts
  	finish_time(beginning)
  	system("touch /tmp/finished")
  end

  desc "Update host networks"
  task :networks => :environment do
  	beginning = start_time
  	puts Network.update_all 
  	finish_time(beginning)
  end

  desc "Update byoc seat information"
  task :seats => :environment do
  	beginning = start_time
  	puts Seat.update_seats
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

