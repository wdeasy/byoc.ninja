class Identity < ApplicationRecord
  include Name

  belongs_to :user

  scope :active, -> { where( enabled: true ).where( banned: false ) }
  scope :specific, -> (provider) { where(:provider => provider).first }

  enum provider: [:steam, :discord, :bnet, :qconbyoc, :twitch]

  def self.find_with_omniauth(auth, user_id=nil)
    if !user_id.nil?
      find_by(user_id: user_id, provider: auth.provider)
    else
      find_by(uid: auth.uid, provider: auth.provider)
    end
  end

  def self.create_with_omniauth(auth)
    create(uid: auth.uid, provider: auth.provider, enabled: true)
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
      puts "Unable to update Discord connections"
      puts e.message
    end

    if response.present?
      doc = JSON.parse(response.body)
      doc.each do |d|
        if ['battlenet', 'steam', 'twitch'].include? d['type']
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
    end
  end

  def update_info(auth)
    if steam?
      update_attributes(
        :uid     => auth.uid,
        :name	   => Name.clean_name(auth.info['nickname']),
        :url 	   => Name.clean_url(auth.extra['raw_info']['profileurl']),
        :avatar  => Name.clean_url(auth.extra['raw_info']['avatar']),
        :enabled => true
      )
    elsif discord?
      update_attributes(
        :uid     => auth.uid,
        :name    => "#{Name.clean_name(auth.extra['raw_info']['username'])}\##{auth.extra['raw_info']['discriminator']}",
        :avatar  => Name.clean_url(auth.info['image']),
        :enabled => true
      )
    elsif bnet?
      update_attributes(
        :uid     => auth.uid,
        :name    => auth.info['battletag'],
        :enabled => true
      )
    elsif twitch?
      update_attributes(
        :uid     => auth.uid,
        :name    => Name.clean_url(auth.extra['raw_info']['display_name']),
        :url 	   => auth.info['urls'].present? ? Name.clean_url(auth.info['urls']['Twitch']) : nil,
        :avatar  => Name.clean_url(auth.info['image']),
        :enabled => true
      )
    end
  end

  def Identity.create_with_qconbyoc(user_id, uid)
    identity = Identity.where(user_id: user_id, provider: :qconbyoc).first_or_initialize
    seat = identity.user.seat.nil? ? nil : identity.user.seat.seat
    if seat.nil?
      identity.update_attributes(uid: uid, name: seat, enabled: false)
    else
      identity.update_attributes(uid: uid, name: seat, enabled: true)
    end
    identity.save
  end

  def Identity.update_qconbyoc
    uri = URI(ENV["QCONBYOC_ENDPOINT"])
    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    begin
      res = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
      end
    rescue => e
      puts "Unable to send update to qconbyoc"
      puts e.message
    end
  end
end
