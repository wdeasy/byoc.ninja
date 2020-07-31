module UsersHelper
  def display_avatar(avatar, options={})
    # size = "_full.jpg"
    # #size = "_medium.jpg"
    # url = ''
    # if !avatar.nil? && (avatar.include? "steam")
  	#    url = avatar.gsub(".jpg", size)
    # else
    #    url = avatar
    # end

    avatar.blank? ? avatar : (image_tag avatar, options)
  end
end
