# Pin npm packages by running ./bin/importmap

# if Rails.env.production?
#   pin "jquery", to: "https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"
#   pin "jquery_ujs", to: "https://cdnjs.cloudflare.com/ajax/libs/jquery-ujs/1.2.3/rails.min.js"
# else
#   pin "jquery", to: "jquery.js" # after ./bin/importmap pin jquery
#   pin "jquery_ujs", to: "jquery_ujs.js"
# end

pin 'application'
pin "@rails/ujs", to: "@rails--ujs.js" # @7.1.3
