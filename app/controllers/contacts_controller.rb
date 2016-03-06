class ContactsController < ApplicationController
  def new
    @contact = Contact.new	
  end

  def create
    @contact = Contact.new(params[:contact])
    if @contact.valid?
      ContactMailer.new(@contact).deliver
      flash[:success] = "Message sent!"
      redirect_to root_url
    else
      render :action => 'new'
    end
  end
end
