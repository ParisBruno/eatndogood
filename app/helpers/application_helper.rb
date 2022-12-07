module ApplicationHelper

  def gravatar_for(user, options = { size: 80 })
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.full_name, class: "img-circle")
  end

  def tl(key, locale=nil)
    locale.nil? ? t(key) : t(key, locale: locale)
  end

  def enclose_tag(html)
    raw_html = Nokogiri::HTML::fragment(html)
    raw_html.children.each do |ele|
      ele.remove if ele.text == ""
    end
    raw_html.to_html.slice(0,250)+'...'
  end

  def payment_methods
    ['cash', 'paypal', 'venmo', 'stripe']
  end

  def is_payment_method?(type)
    current_app_user.selected_payment_methods.include?(type)
  end

  def show_svg(path)
    File.open("app/assets/images/#{path}", "rb") do |file|
      raw file.read
    end
  end

  def week_days
    [['Monday', 0], ['Tuesday', 1], ['Wednesday', 2], ['Thursday', 3], ['Friday', 4], ['Saturday', 5], ['Sunday', 6]]
  end
end
