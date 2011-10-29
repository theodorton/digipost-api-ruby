module Digipost::Api::Representations
  class Address
    attr_accessor :street, :house_number, :zip_code, :city
    
    def initialize(attributes)
      @street       = attributes[:street]
      @house_number = attributes[:house_number]
      @zip_code     = attributes[:zip_code]
      @city         = attributes[:city]
    end
  end
end
