class StaticPagesController < ApplicationController
  def privacy_policy
  	@groups = Group.where(enabled: true).order("name asc")
  end

  def message
  	m = Message.display
    if m != nil
      flash[m["message_type"]] = m["message"]
    end
  end
end