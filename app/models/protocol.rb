class Protocol < ActiveRecord::Base
  has_many :games, :foreign_key => :protocol

  def Protocol.lookup(name) 
    name = name.delete "™®"
    game = Protocol.find_by_name(name)

    if name.include? "Source SDK Base"
      return "source"
    elsif game == nil
      return nil
    else      
      return game.protocol
    end   
  end

  def Protocol.query_server(protocol, ip, port)
  	a = []
  	b = ''
  	IO.popen("php lib/tasks/query.php #{ENV["GAMEQ_PATH"]} #{protocol} #{ip}:#{port}") do |f|
  		b << f.read	
  		b.gsub!("\n","<br />")
  		a << b
  	end
  	return a[0]  	
  end

  def Protocol.update_protocols
    a = []
    IO.popen("php lib/tasks/protocols.php #{ENV["GAMEQ_PATH"]} #{ENV["HOSTNAME"]} #{ENV["DATABASE"]} #{ENV["USERNAME"]} #{ENV["PASSWORD"]}") do |f|
      a << f.read
    end
    return a[0]     
  end
end
