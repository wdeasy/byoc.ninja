class MessagesController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user

  def index
  	@messages = Message.order("updated_at desc")
  end

  def new
    @message = Message.new
  end

  def create
    @message = Message.new(message_params)
    if @message.save
      flash[:success] = "Message added."
      redirect_to messages_url
    else
      render 'new'
    end
  end

  def show
    @message = Message.find_by_id(params[:id])
  end

  def edit
  	@message = Message.find_by_id(params[:id])
  end

  def update
  	@message = Message.find_by_id(params[:id])
    if @message.update_attributes(message_params)
      flash[:success] = "Message updated."
      redirect_to messages_url
    else
      render 'edit'
    end
  end

  def destroy
    Message.find_by_id(params[:id]).destroy
    flash[:success] = "Message deleted"
    redirect_to messages_url
  end

  def clear
    if params[:clear].present?
      @clear = Message.clear_all
      flash[:success] = @clear
      redirect_to messages_clear_url
    end
  end

  private
    def message_params
      params.require(:message).permit(:message, :message_type, :show)
    end

    # Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
        store_location
        redirect_to root_url
      end
    end

    # Confirms an admin user.
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end    
end