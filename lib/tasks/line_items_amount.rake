namespace :line_items_amount do
  desc 'Update amount for all line_items'
  task update_line_items_amount_for: :environment do
    LineItem.where.not(order_id: nil).where(amount: nil, sub_total: nil).each do |line_item|
      sub_total = if line_item.recipe
                     line_item.quantity * line_item.recipe.price
                  elsif line_item.gift_card
                     line_item.quantity * line_item.gift_card.price
                  end

      total_tax = if line_item.recipe && line_item.recipe.is_draft == false
                     sub_total * (line_item.recipe.chef.user.product_tax/100)
                  elsif line_item.gift_card
                     line_item.quantity * 3.95
                  end

      coupon_discount = if line_item.order.coupon_code.present?
                           coupon_code = CouponCode.find_by(title: line_item.order.coupon_code)
                           sub_total * (-1) * (coupon_code.coupon_percent_off.to_f/100)
                        else
                           0.0
                        end

      amount = ((sub_total + coupon_discount + total_tax) * 100).to_i

      line_item.update_columns(amount: amount, sub_total: (sub_total * 100).to_i,
                                total_tax: total_tax.to_f, coupon_discount: coupon_discount.to_f)
    end

    puts 'Line items was succesfully updated'
  end
end
