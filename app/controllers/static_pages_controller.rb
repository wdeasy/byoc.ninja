class StaticPagesController < ApplicationController
  def privacy_policy
  	@groups = Group.where(enabled: true).order("name asc")
  end

  def about
  end
end