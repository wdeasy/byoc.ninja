module ApplicationHelper

# Returns the full title on a per-page basis.
  def full_title(page_title = '')
    base_title = "byoc.ninja"
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end

  def yesno(x)
  	x ? "Yes" : "No"
	end
end