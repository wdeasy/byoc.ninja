module GamesHelper
  def display_image(image, url)
    options = {:class => "img-responsive", :target => "_blank"}
    if image.present? && url.present?
      sanitize link_to image_tag(image), url, options
    elsif image.present?
      sanitize image_tag(image)
    else
      ""
    end
  end
end
