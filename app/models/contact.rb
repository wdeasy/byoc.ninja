class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      record.errors[attribute] << (options[:message] || "is not an email")
    end
  end
end

class Contact
	require 'mailgun'
	include ActiveModel::Validations
	include ActiveModel::Conversion
	extend ActiveModel::Naming

	attr_accessor :name, :email, :message
	validates :name, :email, :message, :presence => true
	validates :email, email: true
	validates :message, length: { maximum: 1000 }

  def initialize(attributes = {})
  	attributes.each do |name, value|
  		send("#{name}=", value)
  	end
  end

  def persisted?
  	false
  end

	def Contact.send_mail(contact)
		mg_client = Mailgun::Client.new ENV["MAILGUN_API"]

		message_params = {:from => contact.email,
											:to => ENV["MAILGUN_EMAIL"],
											:subject => "New message from #{contact.name}",
											:text => contact.message
										}
		begin
			mg_client.send_message ENV["MAILGUN_DOMAIN"], message_params
		rescue => e
			return false
		end		
	end
end