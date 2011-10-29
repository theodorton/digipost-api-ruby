module Digipost::Api::Representations
  class Recipient
    attr_accessor :first_name, :last_name, :address, :digipost_address
    
    def initialize(attributes = {})
      @first_name = attributes[:first_name]
      @last_name  = attributes[:last_name]
      @address    = attributes[:address]
      @digipost_address = attributes[:digipost_address]
    end
  end
end