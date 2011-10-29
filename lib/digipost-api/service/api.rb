require 'httparty'

module Digipost::Api::Service
  class Api
    include HTTParty
    base_uri 'https://api.digipost.no/'
    format :xml
    
    module Configuration
      attr_reader :id, :certificate, :private_key # 179096
      
      def configure(id, certificate, private_key)
        self.id = id
        self.certificate = certificate
        self.private_key = private_key
        headers({
          'Accept' => 'application/vnd.digipost-v1+xml',
          'X-Digipost-UserId' => id
        })
      end
    end
    
    # @return [Hash]
    def relations
      relations = {}
      response = get('/')
      response[:links].each do |link|
        key   = link[:rel].split["digipost.no"].last
        value = link[:uri].split["digipost.no"].last
        relations[key.to_sym] << value
      end
      return relations
    end
  end
end