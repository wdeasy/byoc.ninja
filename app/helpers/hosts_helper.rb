module HostsHelper

	def flags(host)
		html = ''
		if host.flags
			if host.flags['Quakecon in Host Name']
				html << '<span class="glyphicon glyphicon-ok" title="Quakecon in Host Name"></span>'
			end

			if host.flags['BYOC Player in Game']
				html << '<span class="glyphicon glyphicon-user" title="BYOC Player in Game"></span>'
			end

			if host.flags['Hosted in BYOC']
				html << '<span class="glyphicon glyphicon-home" title="Hosted in BYOC"></span>'
			end

			if host.flags['Password Protected']
				html << '<span class="glyphicon glyphicon-lock" title="Password Protected"></span>'
			end

			if host.flags['Last Query Attempt Failed']
				html << '<span class="glyphicon glyphicon-remove" title="Last Query Attempt Failed"></span>'
			end

			if host.flags['Manually Added']
				html << '<span class="glyphicon glyphicon-pushpin" title="Pinned"></span>'
			end

		end

		return html		
	end

	def link(host)
		if host.game.link?
			link_to decolor_name(host.game.name), host.game.link, {:target => "_blank"}
		else
			decolor_name(host.game.name)
		end
	end

	def name(host)
		if host.name.blank? && host.lobby
			"#{display_name(host.users.first)}'s Lobby"
		else
			decolor_name(host.name)
	  end
	end

  def join(host)
    if host.game.appid
    	link_to (host.address ? host.address : "Join Lobby") , host.link
    else
      host.address
    end
  end

  def decolor_name(name)
    if name
      name.gsub!("^1","") 
      name.gsub!("^2","")
      name.gsub!("^3","")
      name.gsub!("^4","")
      name.gsub!("^5","")
      name.gsub!("^6","")
      name.gsub!("^7","")
      name.gsub!("^8","") 
    end

    return strip_tags(name)
  end   
end