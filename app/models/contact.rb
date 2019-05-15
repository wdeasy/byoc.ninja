class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      record.errors[attribute] << (options[:message] || "is not an email")
    end
  end
end

class Contact
	include ActiveModel::Validations
	include ActiveModel::Conversion
	extend ActiveModel::Naming

	attr_accessor :name, :email, :message, :subject
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
end
