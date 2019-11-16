class Network < ApplicationRecord
  has_many :hosts

  def name_cidr
    "#{name} -- #{cidr}"
  end

  def Network.valid_ip(i)
    if i == nil
      return false
    end

    begin
      cidr = NetAddr::IPv4.parse(i)
      return true
    rescue NetAddr::ValidationError
      puts "#{i} is not a valid ip."
      return false
    end
  end

  def Network.location(i)
    network = Network.where(:name => 'wan').first

    if i == nil
      return network.id
    end

    begin
      ip = NetAddr::IPv4.parse(i)
    rescue NetAddr::ValidationError
      puts "Skipping location. #{i} is not a valid ip."
      return network.id
    end

    Network.where.not(:name => 'wan').each do |r|
      if !r.cidr.blank?
        begin
          cidr = NetAddr::IPv4Net.parse(r.cidr)

          if cidr.contains(ip)
            network = r

            if network == "banned"
              return network.id
            end
          end
        rescue NetAddr::ValidationError
          puts "Invalid CIDR: #{r.cidr}"
        end
      end
    end

    return network.id
  end
end
