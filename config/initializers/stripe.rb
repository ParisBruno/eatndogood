# sk_test_51HEAArGj9PVM0RirfwtP5jM8PjsWs5Lblw5hAKdTLkoDeSnowAvTp0XuVIaKyntnDC2HO6FNWYyTQPteTvyNR6li00N5RfwpCn


# if Rails.env.production?
# 	Stripe.api_key	= "sk_test_51Hkyh8JhzcOxD4pHctIVpnzk6HI9jwVUpjjNaecTaVyDFk0dXnx56PEKr82T5AxXocLLb1Etd1PuTl2UlfwLd1KZ00tHQmC9IT"
# 	# Stripe.publishable_key = "pk_test_51Hkyh8JhzcOxD4pH4Fb5eqzK9MTDNFq8OUfRGjyOdTDbeYKNI8wcR714tB9bv0MBCQZP3mI1a0a2v1a31lSbVsLH00VXfz5uOg"
# else
# 	# Stripe.api_key = "sk_PetrB20t2iGGJkwKcGIGYcbTWVRrk"
# 	# STRIPE_PUBLIC_KEY = "pk_RK9htCGb2ats6ATSiq8uewZjJpcbO"
# end

# sk_test_51HEAArGj9PVM0RirfwtP5jM8PjsWs5Lblw5hAKdTLkoDeSnowAvTp0XuVIaKyntnDC2HO6FNWYyTQPteTvyNR6li00N5RfwpCn
Rails.configuration.stripe = {
	:publishable_key => "sk_test_51Hkyh8JhzcOxD4pHctIVpnzk6HI9jwVUpjjNaecTaVyDFk0dXnx56PEKr82T5AxXocLLb1Etd1PuTl2UlfwLd1KZ00tHQmC9IT",
	:secret_key => ""
	}
	
Stripe.api_key = Rails.configuration.stripe[:secret_key]


	
