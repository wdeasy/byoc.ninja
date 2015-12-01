class Network < ActiveRecord::Base
  require "ipaddr"

  def Network.location(i)
    ip = IPAddr.new(i).to_i

    network = 'wan'

    Network.all.each do |r|
      min = IPAddr.new(r.min).to_i      
      max = IPAddr.new(r.max).to_i

      if (min..max)===ip
        network = r.network

        if network == "banned"
          return network
        end
      end
    end

    return network
  end

  def Network.update_all
    i = 0
    Host.all.each do |host|
      network = Network.location(host.ip)
      Host.update_network(host.gameserverip, network)
      i+=1
    end
    return "Updated networks for #{i} hosts." 
  end  
end