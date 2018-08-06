namespace :update do

  desc "Queries host information from steam groups"
  task :hosts => :environment do
    beginning = start_time
    Host.update_hosts
    finish_time(beginning)
    system("touch /tmp/finished")
  end

  desc "Update byoc seat information args[file,year]"
  task :seats, [:file,:year] => :environment do |t, args|
    beginning = start_time
    file = args.file
    year = args.year
    Seat.update_seats(file,year)
    finish_time(beginning)
  end

  desc "Search for hosts by name args[name]"
  task :hosts_by_name, [:name] => :environment do |t, args|
    beginning = start_time
    name = args.name
    Host.update_hosts_by_name(name)
    finish_time(beginning)
    system("touch /tmp/hostsbyname")
  end

  desc "Search for hosts by file args[file]"
  task :hosts_by_file, [:file] => :environment do |t, args|
    beginning = start_time
    file = args.file
    Host.update_hosts_by_file(file)
    finish_time(beginning)
    system("touch /tmp/hostsbyfile")
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

  def start_time
  	beginning = Time.now
  	puts beginning.to_formatted_s(:db)
  	return beginning
  end

  def finish_time(beginning)
  	puts "Time elapsed #{Time.now - beginning} seconds."
  end
end
