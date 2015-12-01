module HostsHelper

	def flags(host)
		html = ''
		
		if host.name != nil
			if host.name.downcase.include? "quakecon"
				if host.name.ends_with? "'s Lobby"
				else
					html << '<span class="glyphicon glyphicon-ok" title="Quakecon in Host Name"></span>'
				end				
			end	
		end

		host.users.each do |user|
			i = 0
			if user.seat.blank?
			else
				i = 1
			end

			if i == 1 or ["quakecon", "qcon"].any? { |q| user.personaname.downcase.include? q }				
				if html.include? "BYOC Player in Game"
				else
					html << '<span class="glyphicon glyphicon-ok" title="BYOC Player in Game"></span>'
				end				
			end
		end

		if host.network == "byoc"
			html << '<span class="glyphicon glyphicon-ok" title="Hosted in BYOC"></span>'
		end

		if host.password == true
			html << '<span class="glyphicon glyphicon-lock" title="Password Protected"></span>'
		end

		if host.respond == false && host.last_successful_query != Time.at(0)
			html << '<span class="glyphicon glyphicon-remove" title="Last Query Attempt Failed"></span>'
		end	

		return html		
	end

	def players(host)
		html = ''

		if host.max.blank?
		else
			if host.current > 0
				html << "#{host.current}"
			else
				html << "#{host.users.size}"
			end
			html << "/#{host.max}"
		end

		return html
	end	
end