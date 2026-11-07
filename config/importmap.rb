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
pin "delegated-events" # @1.1.2
pin "selector-set" # @1.1.5
pin "@hotwired/turbo-rails", to: "@hotwired--turbo-rails.js" # @8.0.23
pin "@hotwired/turbo", to: "@hotwired--turbo.js" # @8.0.23
pin "@rails/actioncable/src", to: "@rails--actioncable--src.js" # @8.1.401
