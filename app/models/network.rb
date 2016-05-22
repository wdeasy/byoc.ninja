class Network < ActiveRecord::Base
  has_many :hosts

  def name_cidr
    "#{name} -- #{cidr}"
  end

  def Network.location(i)
    network = Network.where(:name => 'wan').first

    if i == nil || i.scan(/./).count != 3
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