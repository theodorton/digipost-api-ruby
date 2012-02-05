require 'httparty'
require 'crack'
require 'rsa'

module Digipost::Api
  class Service
    include HTTParty
    base_uri 'https://api.digipost.no'
    format :xml
    
    # cattr_accessor :digipost_user, :certificate, :private_key # 179096
    
    def self.configure(digipost_user, certificate, private_key)
      @@digipost_user = digipost_user
      @@certificate = certificate
      @@private_key = private_key
      # headers({
      #   'Accept' => 'application/vnd.digipost-v1+xml',
      #   'X-Digipost-UserId' => digipost_user
      # })
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
    
    def send_message(message)
      # Create resource at Digipost
      body =  '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      body << '<message xmlns="http://api.digipost.no/schema/v1">'
      body << "<messageId>#{message.id}</messageId>"
      body << "<subject>#{message.subject}</subject>"
      body << "<digipostAddress>#{message.recipient}</digipostAddress>"
      body << "<smsNotification>#{message.sms_notification ? 'true' : 'false'}</smsNotification>"
      body << "<authenticationLevel>PASSWORD</authenticationLevel>"
      body << "</message>"
      
      puts body
      
      response = self.class.post('/messages', {
        body: body,
        headers: {
          'Date' => self.class.date_header(message.date),
          'Content-MD5' => self.class.md5_header(body),
          'Content-Type' => 'application/vnd.digipost-v1+xml'
        }
      })
      
      begin
        post_link = ""
        xml = Crack::XML.parse(response.body)
        xml['message']['link'].each do |el|
          if el["rel"] == "https://api.digipost.no/relations/add_content_and_send"
            post_link = el["uri"].split("digipost.no").last
          end
        end
        
        # Upload message PDF
        response = self.class.post(post_link, {
          body: message.pdf,
          headers: {
            'Date' => date_header(message.date),
            'Content-Type'    => 'application/octet-stream'
          }
        })
        return true
      rescue
        return false
      end
    end
    
    def self.post(uri, options = {})
      # Sign the request
      date = options[:headers]['Date']
      options[:headers] = options[:headers].merge({
        'Accept' => 'application/vnd.digipost-v1+xml',
        'X-Digipost-UserId'    => @@digipost_user.to_s,
        'Content-MD5'          => md5_header(options[:body]),
        'X-Digipost-Signature' => signature(:post, uri, options[:body], date)
      })
      super(uri, options)
    end
    
    def self.get(uri, options = {})
      date = options[:headers]['Date']
      options[:headers] = options[:headers].merge({
        'Accept' => 'application/vnd.digipost-v1+xml',
        'X-Digipost-UserId'    => @@digipost_user.to_s,
        'Content-MD5'          => md5_header(options[:body]),
        'X-Digipost-Signature' => signature(:post, uri, options[:body], date)
      })
      super(uri, options)
    end
    
    def self.signature(method, uri, message, date)
      headers = "#{method.to_s.upcase}\n" +
                "#{uri.downcase}\n" +
                "content-md5: #{md5_header(message)}" +
                "date: #{date}\n" +
                "x-digipost-userid: #{@@digipost_user}\n" +
                "\n"
      return generate_signature(headers)
    end
    
    def self.generate_signature(headers)
      key = OpenSSL::PKey::RSA.new(@@private_key)
      digest = OpenSSL::Digest.new("SHA256")
      return Base64.encode64(key.sign(digest, headers)).split("\n").join
    end
    
    def self.md5_header(payload)
      return Base64.encode64 Digest::MD5.digest(payload)
    end
    
    def self.date_header(date)
      # Wed, 29 Jun 2011 14:58:11 GMT
      date.strftime("%a, %e %b %Y %H:%M:%S GMT")
    end
  end
end