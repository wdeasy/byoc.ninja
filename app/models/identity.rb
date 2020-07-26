class Identity < ApplicationRecord
  belongs_to :user

  enum provider: [:steam, :discord]

  def self.find_with_omniauth(auth)
    find_by(uid: auth.uid, provider: auth.provider)
  end

  def self.create_with_omniauth(auth)
    create(uid: auth.uid, provider: auth.provider)
  end

  def update_info(auth)
    if steam?
      update_attributes(
        :name	   => auth.info['nickname'],
        :url 	   => auth.extra['raw_info']['profileurl'],
        :avatar  => auth.extra['raw_info']['avatar']
      )
    elsif discord?
      update_attributes(
        :name => "#{auth.extra['raw_info']['username']}\##{auth.extra['raw_info']['discriminator']}",
        :avatar   => auth.info['image']
      )
    end
  end
end
