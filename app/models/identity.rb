class Identity < ApplicationRecord
  include Name

  belongs_to :user

  scope :active, -> { where( enabled: true ) }
  scope :specific, -> (provider) { where(:provider => provider).first }

  enum provider: [:steam, :discord, :bnet]

  def self.find_with_omniauth(auth)
    find_by(uid: auth.uid, provider: auth.provider)
  end

  def self.create_with_omniauth(auth)
    create(uid: auth.uid, provider: auth.provider)
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

        # if provider == :steam && identity.user_id.present? && user_id != identity.user_id
        #  unless user.banned || identity.user.banned
        #   ids = Identity.where(user_id: identity_user_id).where.not(uid: d['id'])
        #   if ids.blank?
        #     User.destroy(identity.user_id)
        #   end
        #  end
        # end

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
end
