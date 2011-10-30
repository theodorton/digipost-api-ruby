require 'httparty'
require 'uri'

module Digipost::Api::Service
  class CryptApi
    include HTTParty
    base_uri 'http://djtnt.mine.nu:80'
    
    def encrypt(private_key, data)
      # puts "#{private_key} : #{data}"
      return self.class.get("/encrypt?data=#{URI.escape(data)}").body
    end
  end
end