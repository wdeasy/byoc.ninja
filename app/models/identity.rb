class Identity < ApplicationRecord
  include Name

  belongs_to :user

  scope :active, -> { where( enabled: true ).where( banned: false ) }
  scope :specific, -> (provider) { where(:provider => provider).first }

  enum provider: [:steam, :discord, :bnet, :twitch]

  def self.find_with_omniauth(auth, user_id=nil)
    if user_id.present?
      find_by(user_id: user_id, provider: auth.provider)
    else
      find_by(uid: auth.uid, provider: auth.provider)
    end
  end

  def self.create_with_omniauth(auth)
    identity = create(uid: auth.uid, provider: auth.provider, enabled: true)

    case identity.provider.to_sym
    when :steam
      identity.update(
        :name	   => Name.clean_name(auth.info['nickname']),
        :url 	   => Name.clean_url(auth.extra['raw_info']['profileurl']),
        :avatar  => Name.clean_url(auth.extra['raw_info']['avatar'])
      )
    when :discord
      identity.update(
        :name    => "#{Name.clean_name(auth.extra['raw_info']['username'])}\##{auth.extra['raw_info']['discriminator']}",
        :avatar  => Name.clean_url(auth.info['image'])
      )
    when :bnet
      identity.update(
        :name    => auth.info['battletag']
      )
    when :twitch
      identity.update(
        :name    => Name.clean_name(auth.extra['raw_info']['display_name']),
        :url 	   => auth.info['urls'].present? ? Name.clean_url(auth.info['urls']['Twitch']) : nil,
        :avatar  => Name.clean_url(auth.info['image'])
      )
    end

    return identity
  end

  def update_info(auth)
    update_attribute(:uid, auth.uid) unless uid == auth.uid
    update_attribute(:enabled, true) unless enabled == true

    case provider.to_sym
    when :steam
      unless name == auth.info['nickname']
        update_attribute(:name, Name.clean_name(auth.info['nickname']))
      end

      unless url == auth.extra['raw_info']['profileurl']
        update_attribute(:url, Name.clean_url(auth.extra['raw_info']['profileurl']))
      end

      unless avatar == auth.extra['raw_info']['avatar']
        update_attribute(:avatar, Name.clean_url(auth.extra['raw_info']['avatar']))
      end
    when :discord
      unless name == "#{auth.extra['raw_info']['username']}\##{auth.extra['raw_info']['discriminator']}"
        update_attribute(:name, "#{Name.clean_name(auth.extra['raw_info']['username'])}\##{auth.extra['raw_info']['discriminator']}")
      end

      unless url == auth.extra['raw_info']['profileurl']
        update_attribute(:url, Name.clean_url(auth.extra['raw_info']['profileurl']))
      end
    when :bnet
      unless name == auth.info['battletag']
        update_attribute(:name, Name.clean_name(auth.info['battletag']))
      end
    when :twitch
      unless name == auth.extra['raw_info']['display_name']
        update_attribute(:name, Name.clean_name(auth.extra['raw_info']['display_name']))
      end

      unless url == auth.info['urls']['Twitch']
        update_attribute(:url, Name.clean_url(auth.info['urls']['Twitch']))
      end

      unless avatar == auth.info['image']
        update_attribute(:avatar, Name.clean_url(auth.info['image']))
      end
    end

    update_attribute(:clan, Name.get_clan(name))
    update_attribute(:handle, Name.get_handle(name))
  end

  def Identity.update_qconbyoc
    seats = Seat.where(updated: false)
    seats.each do |seat|
      uri = URI.parse("#{ENV["QCONBYOC_ENDPOINT"]}?seat=#{seat.seat}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER

      req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
      req.body = 'update'
      begin
        puts "Sending #{seat.seat} to qconbyoc"
        http.request(req)
        seat.update_attribute(:updated, :true)
      rescue => e
        puts "Unable to send update to qconbyoc"
        puts e.message
      end
    end
  end

  def Identity.update(id, auth, seat=nil)
    identity = Identity.find_by(id: id)
    return if (identity.banned? || identity.user.banned?)

    result = nil
    identity.update_info(auth)
    User.update_with_omniauth(identity.user_id, identity.name)

    if seat.present?
      result = User.update_seat_from_omniauth(identity.user_id, seat)
    end

    return result
  end

  def Identity.update_with_omniauth(auth, user_id=nil)
    identity = Identity.find_with_omniauth(auth)
    if user_id.present? && identity.blank?
      identity = Identity.find_with_omniauth(auth, user_id)
    end

    if identity.blank?
      identity = Identity.create_with_omniauth(auth)
    end

    if user_id.present? && identity.user_id != user_id
      identity.user_id = user_id
      identity.save
    end

    unless identity.user.present?
      user = User.create_with_omniauth
      identity.user = user
      identity.save
    end

    return identity
  end
end
