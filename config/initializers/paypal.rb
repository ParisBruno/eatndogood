if Rails.env.development? || Rails.env.staging?
	Rails.configuration.paypal = {
		client_id: "AQK4qrPRygRU-GhNrHHxXlcCoZQfsdPvmKnquVFyEJJJu72gmijkaJn5H-5TjiyEtPcKU-hWsGCdOwyC",
		client_secret: "EOdkwiKgMTDNQG_D10pwYDQgZmg6D2uQ1wGHlCXUz4gCwcQlfy5MXZzbZP9kw31cv2eqDlqBsrQj_9Gj",
		env: 'sanbox'
	}
else
	Rails.configuration.paypal = {
		client_id: ENV['PAYPAL_CLIENT_ID'],
		client_secret: ENV['PAYPAL_CLIENT_SECRET'],
		env: 'live'
	}
end
