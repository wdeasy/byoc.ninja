class ContactMailer < ActionMailer::Base
  default from: "#{message.name} <#{message.email}>"
  default to: "byoc.ninja <#{ENV["EMAIL_USERNAME"]}>"

  def new(message)
    @message = message
    
    mail subject: "BYOC.NINJA >> Message from #{message.name} <#{message.email}>"
  end
end