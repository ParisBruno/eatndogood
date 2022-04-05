if Rails.env.development? || Rails.env.staging?
	Rails.configuration.stripe = {
		publishable_key: "pk_test_51KkQ1gSBroUK4gY7h0SqYuZUILiJ41BSuR1nQhrrxYacvHlm9Ot5xHLyAFlUjs2MzgujI0Ep0al7KrdvctcHbc5o00Z7beUF0Q",
		secret_key: "sk_test_51KkQ1gSBroUK4gY7QHpunSLV0OA8YzLf8UqFCV4K5UviqnlccSkLFVPeysBIGHBJYInyFPzen530VyqM78Gpk4x000iX7BwgBS"
	}
else
	Rails.configuration.stripe = {
		publishable_key: ENV['TEST_STRIPE_PUBLISHABLE_KEY'],
		secret_key: ENV['TEST_STRIPE_SECRET_KEY']
	}
end
