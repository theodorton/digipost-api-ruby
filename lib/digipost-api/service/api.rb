require 'httparty'
require 'crack'
require 'rsa'

module Digipost::Api::Service
  class Api
    include HTTParty
    base_uri 'https://api.digipost.no'
    format :xml
    
    cattr_accessor :digipost_user, :certificate, :private_key # 179096
    
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
      
      response = self.class.post('/messages', {
        body: body,
        headers: {
          'Date' => date_header(message.date),
          'Content-MD5' => self.class.md5_header(body),
          'Content-Type' => 'application/vnd.digipost-v1+xml'
        }
      })
      
      post_link = ""
      
      # response.body['message'].each_element do |el|  
      begin 
        xml = Crack::XML.parse(response.body)
        xml['message']['link'].each do |el|
          if el["rel"] == "https://api.digipost.no/relations/add_content_and_send"
            post_link = el["uri"].split("digipost.no").last
          end
        end
      rescue NoMethodError
        puts response.body.inspect
      end
      # puts post_link
      
      # Check response!
      # puts("Digipush response (new):")
      # puts(response.body.inspect.split("\n").join("<br />"))
      
      # Upload message attachments
      response = self.class.post(post_link, {
        body: message.pdf,
        headers: {
          'Date' => date_header(message.date),
          'Content-Type'    => 'application/octet-stream'
        }
      })
      
      puts response.body
      
      # Return result/status from API request
      # puts("Digipush response (create):")
      # puts(response.body.inspect.split("\n").join("<br />"))
      return true
    end
    
    def self.post(uri, options = {})
      # Sign the request
      date = options[:headers]['Date']
      options[:headers] = options[:headers].merge({
        'Accept' => 'application/vnd.digipost-v1+xml',
        'X-Digipost-UserId'    => digipost_user.to_s,
        'Content-MD5'          => md5_header(options[:body]),
        'X-Digipost-Signature' => signature(:post, uri, options[:body], date)
      })
      # puts options[:headers]
      # puts options[:body]
      super(uri, options)
    end
    
    def self.signature(method, uri, message, date)
      headers = "#{method.to_s.upcase}\n" +
                "#{uri.downcase}\n" +
                "content-md5: #{md5_header(message)}" +
                "date: #{date}\n" +
                "x-digipost-userid: #{digipost_user}\n" +
                "\n"
      # puts(headers)
      # digest   = Digest::SHA256.digest(headers)
      # key = OpenSSL::PKey::RSA.new(self.private_key)
      # digest = key.private_encrypt(digest)
      # hash = Base64.strict_encode64(digest)
      # puts "DIGEST:#{hash}"
      puts headers
      encrypter = CryptApi.new
      signature_string = encrypter.encrypt(headers).to_s
      return signature_string 
    end
    
    def self.md5_header(payload)
      return Base64.encode64 Digest::MD5.digest(payload)
    end
    
    def date_header(date)
      # Wed, 29 Jun 2011 14:58:11 GMT
      date.strftime("%a, %e %b %Y %H:%M:%S GMT")
    end
  end
end