class ContactMailer < ActionMailer::Base
  default from: "byoc.ninja <#{ENV["EMAIL_ADDRESS"]}>"
  default to: "byoc.ninja <#{ENV["EMAIL_ADDRESS"]}>"

  def email(msg)
    @msg = msg

    mail from: "#{msg.name} <#{msg.email}>"
    mail subject: "BYOC.NINJA >> Message from #{msg.name} <#{msg.email}>"
  end
end
