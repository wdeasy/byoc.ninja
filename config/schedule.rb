env:PATH, ENV['PATH']

every 1.minute do
	rake "update:servers"
end

every 1.day, :at => '12:00am' do
	rake "update:seats"
end

every :tuesday, :at => '9:00am' do
	rake "update:protocols"
end

every :tuesday, :at => '10:00am' do
	rake "cleanup:servers"
end