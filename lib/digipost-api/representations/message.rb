module Digipost::Api::Representations
  class Message
    attr_accessor :id, :recipient, :subject, :authentication_level,
                  :sms_notification, :pdf, :date
    
    def initialize(attributes)
      @recipient = attributes[:recipient]
      @subject   = attributes[:subject]
      @authentication_level = attributes[:authentication_level]
      @sms_notification = attributes[:sms_notification]
      @pdf = attributes[:pdf]
      @date = attributes[:date]
    end
  end
end