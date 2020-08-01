module UsersHelper
  def display_avatar(avatar, options={})
    # size = "_full.jpg"
    # #size = "_medium.jpg"
    # url = ''
    # if !avatar.nil? && (avatar.include? "steam")
  	#    url = avatar.gsub(".jpg", size)
    # else
    #    url = avatar
    # end

    avatar.blank? ? avatar : (image_tag avatar, options)
  end

  def provider_link(provider)
    if provider != 'qconbyoc'
      link_to "Link Account", "/auth/#{provider}", method: :post
    else
      link_to "Link your seat", "https://qconbyoc.com"
    end
  end

  def provider_name(provider, identities)
    if identities.pluck(:provider).include? provider
      identity = identities.specific(provider).name
    else
      provider_link(provider)
    end
  end
end
