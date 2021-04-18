# Load Dragonfly if it isn't loaded already.
require 'dragonfly'
require 'dragonfly/s3_data_store'

Dragonfly.app(:ckeditor).configure do
  plugin :imagemagick
  secret "3cd93b972c8cf35a188b4c59c376639bedd620397fbe4a8ac6ef43cb1989dc44"

  # Store files in public/uploads/ckeditor. This is not
  # mandatory and the files don't even have to be stored under
  # public. See http://markevans.github.io/dragonfly/data-stores
  # if Rails.env.production?
    datastore :s3,
      bucket_name: ENV['AWS_BUCKET'],
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_ACCESS_KEY_SECRET'],
      region: 'us-east-1'
  # else
  #   datastore :file, root_path: Rails.root.join('public/uploads/ckeditor', Rails.env).to_s,
  #                  server_root: 'public'
  # end
  # Accept asset requests on /ckeditor_assets. Again, this path is
  # not mandatory. Just be sure to include :job somewhere.
  url_format '/uploads/ckeditor/:job/:basename.:format'
end

Rails.application.middleware.use Dragonfly::Middleware, :ckeditor
