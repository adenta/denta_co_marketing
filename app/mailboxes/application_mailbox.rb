class ApplicationMailbox < ActionMailbox::Base
  routing :all => :inbound_forwarding
end
