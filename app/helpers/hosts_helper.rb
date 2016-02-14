module HostsHelper

	def flags(host)
		html = ''
			if !host.flags.blank?
			if host.flags.include? "Quakecon in Host Name"
				html << '<span class="glyphicon glyphicon-ok" title="Quakecon in Host Name"></span>'
			end

			if host.flags.include? "BYOC Player in Game"
				html << '<span class="glyphicon glyphicon-ok" title="BYOC Player in Game"></span>'
			end

			if host.flags.include? "Hosted in BYOC"
				html << '<span class="glyphicon glyphicon-ok" title="Hosted in BYOC"></span>'
			end

			if host.flags.include? "Password Protected"
				html << '<span class="glyphicon glyphicon-lock" title="Password Protected"></span>'
			end

			if host.flags.include? "Last Query Attempt Failed"
				html << '<span class="glyphicon glyphicon-remove" title="Last Query Attempt Failed"></span>'
			end
		end

		return html		
	end	
end