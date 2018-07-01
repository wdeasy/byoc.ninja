class Network < ActiveRecord::Base
  has_many :hosts

  def name_cidr
    "#{name} -- #{cidr}"
  end

  def Network.valid_ip(i)
    if i == nil
      return false
    end

    begin
      cidr = NetAddr::CIDR.create("#{i}/24")
      #cidr = NetAddr::IPv4.parse(i)
      return true
    rescue NetAddr::ValidationError
      puts "#{i} is not a valid ip."
      return false
    end
  end

  def Network.location(i)
    network = Network.where(:name => 'wan').first

    if i == nil
      return network
    end

    Network.where.not(:name => 'wan').each do |r|
      if !r.cidr.blank?
        cidr = NetAddr::CIDR.create(r.cidr)

        if cidr.matches?(i)
          network = r

          if network == "banned"
            return network
          end
        end
      end
    end

    return network
  end
end
