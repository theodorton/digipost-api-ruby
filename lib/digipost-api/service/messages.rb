require 'digest/md5'

module Digipost::Api::Service
  class Messages < Api
    def self.send_message(message)
      # Create resource at Digipost
      body =  '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      body << '<message xmlns="http://api.digipost.no/schema/v1">'
      body << "<messageId>#{message.id}</messageId>"
      body << "<subject>#{message.subject}</subject>"
      body << "<digipostAddress>#{message.recipient.digipost_address}</digipostAddress>"
      body << "<smsNotification>#{message.sms_notification ? 'true' : 'false'}</smsNotification>"
      body << "<authenticationLevel>PASSWORD</authenticaitonLevel>"
      body << "</message>"
      
      response = post('/messages', {
        body: body,
        headers: {
          'X-Digipost-Date' => date_header(message.date),
          'X-Digipost-UserId' => Configuration.id,
          'Content-MD5' => Digest::MD5.digest(body)
        }
      })
      
      # Check response!
      unless response.success?
        return { result: "Failure" }
      end
      
      # Upload message attachments
      post("/relations/messages/#{message.id}", {
        body: message.pdf,
        headers: {
          'X-Digipost-Date' => date_header(message.date),
          'Content-Type'    => 'application/octet-stream'
        }
      })
      end
      
      # Return result/status from API request
      return { result: "Success!" }
    end
    
    def post(uri, options = {})
      # Sign the request
      date = options[:headers]['X-Digipost-Date']
      options[:headers].merge({
        'Content-MD5'          => md5_header(options[:body])
        'X-Digipost-Signature' => signature(:post, uri, options[:body], date)
      })
    end
    
    def self.signature(method, uri, message, date)
      headers = "#{method.to_s.upcase}\n" +
                "#{uri.downcase}\n" +
                "content-md5: #{md5_header(message)}\n" +
                "date: #{date}"
                "x-digipost-userid: #{Configuration.id}\n" +
                "\n"
      digest   = Digest::SHA256.digest(headers)
      key_pair = RSA::KeyPair.new(Configuration.private_key, Configuration.certificate)
      key_pair.sign(digest)
      return Base64.encode64(digest)
    end
    
    def self.md5_header(payload)
      Digest::MD5.digest(payload)
    end
    
    def self.date_header(date)
      # Wed, 29 Jun 2011 14:58:11 GMT
      date.strftime("%a, %e %b %Y %H:%M:%S GMT")
    end
    
    # String stringToSign = uppercase(verb) + "\n" +
    #                        lowercase(path) + "\n" +
    #                        "content-md5: " + md5Header + "\n" +
    #                        "date: " + datoHeader + "\n" +
    #                        "x-digipost-userid: " + virksomhetsId + "\n" +
    #                        lowercase(urlencode(requestparametre)) + "\n";
    # 
    #  String signature =    base64(sign(stringToSign));
  end
end