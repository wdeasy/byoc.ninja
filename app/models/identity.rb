class Identity < ApplicationRecord
  include Name

  belongs_to :user

  scope :active, -> { where( enabled: true ) }
  scope :specific, -> (provider) { where(:provider => provider).first }

  enum provider: [:steam, :discord, :bnet, :qconbyoc]

  def self.find_with_omniauth(auth)
    find_by(uid: auth.uid, provider: auth.provider)
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
    response = http.request(request)

    doc = JSON.parse(response.body)
    doc.each do |d|
      if ['battlenet', 'steam'].include? d['type']
        provider = d['type'] == 'battlenet' ? :bnet : :steam
        identity = Identity.where(uid: d['id'], provider: provider).first_or_create

        identity.update_attributes(
          :name    => Name.clean_name(d['name']),
          :user_id => user_id,
          :enabled => ActiveModel::Type::Boolean.new.cast(d['visibility'])
        )
      end
    end
  end

  def update_info(auth)
    if steam?
      update_attributes(
        :name	   => Name.clean_name(auth.info['nickname']),
        :url 	   => Name.clean_url(auth.extra['raw_info']['profileurl']),
        :avatar  => Name.clean_url(auth.extra['raw_info']['avatar']),
        :enabled => true
      )
    elsif discord?
      update_attributes(
        :name    => "#{Name.clean_name(auth.extra['raw_info']['username'])}\##{auth.extra['raw_info']['discriminator']}",
        :avatar  => Name.clean_url(auth.info['image']),
        :enabled => true
      )
    end
  end

  def Identity.create_with_qconbyoc(user_id, uid)
    identity = Identity.where(uid: uid, user_id: user_id, provider: :qconbyoc, enabled: true).first_or_create
    seat = identity.user.seat.nil? ? nil : identity.user.seat.seat
    identity.update_attributes(uid: uid, name: seat)
  end

  def Identity.update_qconbyoc(user_id)
    unless ENV["QCONBYOC_ENDPOINT"].nil?
      user = User.find_by(:id => user_id)
      unless user.nil?
        uri = URI(ENV["QCONBYOC_ENDPOINT"])
        req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        req.body = user.as_json
        res = Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(req)
        end
      end
    end
  end
end
