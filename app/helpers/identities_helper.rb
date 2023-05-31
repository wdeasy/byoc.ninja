module IdentitiesHelper
  def display_avatar(avatar, url)
    options = {:class => "img-responsive", :target => "_blank"}
    size = "_full.jpg"
    #size = "_medium.jpg"

    if avatar.present? && (avatar.include? "steam")
  	   avatar = avatar.gsub(".jpg", size)
    end

    if avatar.present? && url.present?
      sanitize link_to image_tag(avatar), url, options
    elsif avatar.present?
      sanitize image_tag avatar
    else
      nil
    end
  end

  def provider_link(provider)
    link_to "Link", "/auth/#{provider}", method: :post
  end

  def provider_unlink(provider, identities)
    if identities.pluck(:provider).include? provider
      link_to "Unlink", unlink_identity_path(identities.specific(provider).id), method: :post
    else
      provider_link(provider)
    end
  end

  def provider_name(provider, identities)
    if identities.pluck(:provider).include? provider
      identity = identities.specific(provider).name
    else
      nil
    end
  end

  def qconbyoc_link(name=nil, seat=nil)
    if seat.present?
      link_to name, "https://www.qconbyoc.com?selected=#{seat}##{seat}", :target => "_new"
    else
      link_to name, "https://www.qconbyoc.com", :target => "_new"
    end
  end

  def qconbyoc_unlink(seat=nil)
    if seat.present?
      link_to "Unlink", seats_unlink_url, method: :post
    else
      link_to "Link", "https://www.qconbyoc.com", :target => "_new"
    end
  end
end
