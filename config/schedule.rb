env:PATH, ENV['PATH']

every 1.minute do
	rake "update:hosts"
end

every 1.day, :at => '12:00am' do
	rake "update:seats"
end

every :tuesday, :at => '10:00am' do
	rake "cleanup:hosts"
end