namespace :cleanup do

  desc "Delete inactive servers"
  task :servers => :environment do
  	beginning = start_time
  	Server.where("updated_at < ? AND banned IS FALSE AND auto_update IS TRUE", 1.week.ago).delete_all
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
