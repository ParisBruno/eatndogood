cart_ids_with = Cart.joins(:line_items).pluck(:id).uniq
Cart.where.not(id: cart_ids_with).where('created_at > ?', Date.new(2021, 10, 1))