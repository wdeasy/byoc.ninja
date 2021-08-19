module HostsHelper

	def flags(f)
		html = ''
		if f.present?
			if f[:name]
				html << '<span class="glyphicon glyphicon-ok" title="Quakecon in Host Name"></span>'
			end

			if f[:player]
				html << '<span class="glyphicon glyphicon-user" title="BYOC Player in Game"></span>'
			end

			if f[:host]
				html << '<span class="glyphicon glyphicon-home" title="Hosted in BYOC"></span>'
			end

			if f[:password]
				html << '<span class="glyphicon glyphicon-lock" title="Password Protected"></span>'
			end

			if f[:unreachable]
				html << '<span class="glyphicon glyphicon-remove" title="Last Query Attempt Failed"></span>'
			end

			if f[:manual]
				html << '<span class="glyphicon glyphicon-pushpin" title="Pinned"></span>'
			end

			if f[:file]
				html << '<span class="glyphicon glyphicon-transfer" title="Found by qclan.info"></span>'
			end

		end

		return html
	end

	def link(url, name, appid)
		if url.present?
			link_to name, "steam://store/#{appid}"
		else
			name
		end
	end

  def join(multiplayer, address, url)
    if multiplayer == true && url.present?
    	link_to (address.present? ? address : "Join Lobby") , url
    else
      address
    end
  end
end
