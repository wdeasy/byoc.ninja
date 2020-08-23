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
      identity.update_attributes(
        :name	   => Name.clean_name(auth.info['nickname']),
        :url 	   => Name.clean_url(auth.extra['raw_info']['profileurl']),
        :avatar  => Name.clean_url(auth.extra['raw_info']['avatar'])
      )
    when :discord
      identity.update_attributes(
        :name    => "#{Name.clean_name(auth.extra['raw_info']['username'])}\##{auth.extra['raw_info']['discriminator']}",
        :avatar  => Name.clean_url(auth.info['image'])
      )
    when :bnet
      identity.update_attributes(
        :name    => auth.info['battletag']
      )
    when :twitch
      identity.update_attributes(
        :name    => Name.clean_url(auth.extra['raw_info']['display_name']),
        :url 	   => auth.info['urls'].present? ? Name.clean_url(auth.info['urls']['Twitch']) : nil,
        :avatar  => Name.clean_url(auth.info['image'])
      )
    end

    return identity
  end

  def self.update_connections(token, user_id)
    uri = URI.parse("https://discord.com/api/users/@me/connections")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    request = Net::HTTP::Get.new(uri.request_uri)
    request["Authorization"] = "Bearer #{token}"
    request["Content-Type"] = 'application/x-www-form-urlencoded'

    begin
      response = http.request(request)
    rescue => e
      logger.info "Unable to update Discord connections"
      logger.info e.message
    end

    return unless response.present?

    doc = JSON.parse(response.body)
    doc.each do |d|
      next unless  ['battlenet', 'steam', 'twitch'].include? d['type']

      case d['type']
      when 'battlenet'
        provider = :bnet
      when 'steam'
        provider = :steam
      when 'twitch'
        provider = :twitch
      end

      identity = Identity.where(user_id: user_id, provider: provider).first_or_initialize
      if identity.banned == false && identity.user.auto_update == true
        identity.update_attributes(
          :uid     => d['id'],
          :name    => Name.clean_name(d['name']),
          :enabled => identity.enabled.nil? ? ActiveModel::Type::Boolean.new.cast(d['visibility']) : identity.enabled
        )
      else
        identity.update_attributes(
          :uid     => identity.uid.nil? ? d['id'] : identity.uid,
          :enabled => identity.enabled.nil? ? ActiveModel::Type::Boolean.new.cast(d['visibility']) : identity.enabled
        )
      end
      identity.save
    end
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
  end

  def Identity.update_qconbyoc
    seats = Seat.where(updated: false).pluck(:seat)
    seats.each do |seat|
      uri = URI.parse("#{ENV["QCONBYOC_ENDPOINT"]}?seat=#{seat}")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER

      req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
      req.body = 'update'
      http.request(req)
      begin
        http.request(req)
      rescue => e
        logger.info "Unable to send update to qconbyoc"
        logger.info e.message
      end
    end
  end

  def Identity.update(id, auth, token=nil, seat=nil)
    identity = Identity.find_by(id: id)
    return if (identity.banned? || identity.user.banned?)

    result = nil
    identity.update_info(auth)
    if identity.discord?
      User.update_with_omniauth(identity.user_id, identity.name)
      Identity.update_connections(token, identity.user_id)
    end
    
    result = User.update_seat_from_omniauth(identity.user_id, seat) if seat.present?

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
