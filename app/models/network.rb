class Network < ActiveRecord::Base
  has_many :hosts

  def name_cidr
    "#{name} -- #{cidr}"
  end

  def Network.location(i)
    network = Network.where(:name => 'wan').first

    if i == 'lobby'
      return network.id
    end

    #Network.all.each do |r|
    Network.where.not(:name => 'wan').each do |r|
      if !r.cidr.blank?
        cidr = NetAddr::CIDR.create(r.cidr)

        if cidr.contains?(i)
          network = r

          if network == "banned"
            return network.id
          end
        end
      end
    end

    return network.id
  end


  def Network.update_all
    i = 0
    #Host.all.each do |host|
    Host.where.not(:ip => nil).each do |host|
      network = Network.location(host.ip)
      Host.update_network(host.address, network)
      i+=1
    end
    return "Updated networks for #{i} hosts." 
  end  
end