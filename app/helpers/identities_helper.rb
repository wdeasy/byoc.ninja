module IdentitiesHelper
  def provider_link(provider)
    if provider != 'qconbyoc'
      link_to "Link", "/auth/#{provider}", method: :post
    else
      link_to "Link", "https://qconbyoc.com"
    end
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
end
