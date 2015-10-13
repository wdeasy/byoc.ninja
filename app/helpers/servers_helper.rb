module ServersHelper

	def flags(server)
		html = ''
		
		if server.name != nil
			if server.name.downcase.include? "quakecon"
				if server.name.ends_with? "'s Lobby"
				else
					html << '<span class="glyphicon glyphicon-ok" title="Quakecon in Server Name"></span>'
				end				
			end	
		end

		server.users.each do |user|
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

		if server.network == "byoc"
			html << '<span class="glyphicon glyphicon-ok" title="Hosted in BYOC"></span>'
		end

		if server.password == true
			html << '<span class="glyphicon glyphicon-lock" title="Password Protected"></span>'
		end

		if server.respond == false && server.last_successful_query != Time.at(0)
			html << '<span class="glyphicon glyphicon-remove" title="Last Query Attempt Failed"></span>'
		end	

		return html		
	end

	def players(server)
		html = ''

		if server.max.blank?
		else
			if server.current > 0
				html << "#{server.current}"
			else
				html << "#{server.users.size}"
			end
			html << "/#{server.max}"
		end

		return html
	end	
end