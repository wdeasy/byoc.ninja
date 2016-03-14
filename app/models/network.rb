class Network < ActiveRecord::Base
  has_many :hosts

  def name_cidr
    "#{name} -- #{cidr}"
  end

  def Network.location(i)
    network = Network.where(:name => 'wan').first

    if i == nil
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
end