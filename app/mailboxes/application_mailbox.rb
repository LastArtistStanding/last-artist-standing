class ApplicationMailbox < ActionMailbox::Base
  routing :all => :incomings
end
