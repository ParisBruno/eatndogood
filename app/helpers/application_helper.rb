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
    max_slice_number = 250
    display_html = raw_html.to_html.slice(0, max_slice_number)
    sliced_words = Nokogiri::HTML::fragment(display_html).text.split(" ")
    while sliced_words.count < 6 do
      max_slice_number = max_slice_number + 250
      display_html = raw_html.to_html.slice(0, max_slice_number)
      sliced_words = Nokogiri::HTML::fragment(display_html).text.split(" ")
    end

    display_html+'...'
  end

  def payment_methods
    ['cash', 'paypal', 'venmo', 'stripe']
  end

  def is_payment_method?(type)
    @sessioned_user.selected_payment_methods.include?(type)
  end

  def show_svg(path)
    File.open("app/assets/images/#{path}", "rb") do |file|
      raw file.read
    end
  end

  def week_days
    [['Monday', 0], ['Tuesday', 1], ['Wednesday', 2], ['Thursday', 3], ['Friday', 4], ['Saturday', 5], ['Sunday', 6]]
  end

  def get_plan_price(guests)
    plan = Stripe::Plan.retrieve(ENV["#{guests}_PRODUCT"])
    "$#{(plan.amount.to_i / 100.0).to_i}/month"
  end

  def app_route(path, options = {})
    if params[:app].nil? && path == "/rockystepswaylive"
      "/"
    else
      params[:app].nil? ? path.remove("/rockystepswaylive") : path
    end
  end
end
