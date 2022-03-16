if Rails.env.development? || Rails.env.staging?
	Rails.configuration.stripe = {
		publishable_key: "pk_test_51Hkyh8JhzcOxD4pH4Fb5eqzK9MTDNFq8OUfRGjyOdTDbeYKNI8wcR714tB9bv0MBCQZP3mI1a0a2v1a31lSbVsLH00VXfz5uOg",
		secret_key: "sk_test_51Hkyh8JhzcOxD4pHctIVpnzk6HI9jwVUpjjNaecTaVyDFk0dXnx56PEKr82T5AxXocLLb1Etd1PuTl2UlfwLd1KZ00tHQmC9IT"
	}
else
	Rails.configuration.stripe = {
		publishable_key: ENV['TEST_STRIPE_PUBLISHABLE_KEY'],
		secret_key: ENV['TEST_STRIPE_SECRET_KEY']
	}
end
