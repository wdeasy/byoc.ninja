class ContactsController < ApplicationController
  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(params[:contact])
    if @contact.valid? && params[:plr].present? &&
      params[:plr].gsub(/[^0-9A-Za-z]/, '').downcase == 'rockets'
        ContactMailer.email(@contact).deliver
        flash[:success] = "Message sent!"
        redirect_to root_url
    else
      puts "Spam bot detected."
      flash[:danger] = "Wrong answer!"
      render :action => 'new'
    end
  end
end
