namespace :update do

  desc "Queries server information from steam groups"
  task :servers => :environment do
  	beginning = start_time
  	puts Server.update_servers
  	finish_time(beginning)
  	system("touch /tmp/finished")
  end

  desc "Update GameQ protocols" 
  task :protocols => :environment do
  	beginning = start_time   	
  	puts Protocol.update_protocols
  	finish_time(beginning)  	
  end

  desc "Update server networks"
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

