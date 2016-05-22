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
				html << '<span class="glyphicon glyphicon-pencil" title="Manually Added"></span>'
			end

		end

		return html		
	end		
end