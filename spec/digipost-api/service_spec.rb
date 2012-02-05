require 'digipost-api'
require 'rspec'
require 'openssl'
require 'base64'

DIR = 'spec/digipost-api/examples/'

pk_filename = 'spec/digipost-api/private_key'
if !File.exists?(pk_filename)
  raise("Please add your private key to `#{pk_filename}'")
end

module Digipost::Api
  describe Service do
    before(:all) do
      pk_filename = 'spec/digipost-api/private_key'
      Service.configure(179069, '', File.new(pk_filename).read)
    end

    it "should generate correct signatures 1" do
      given_headers = File.new(DIR + 'a.head').read
      exp_signature = File.new(DIR + 'a.sig').read
      Service.generate_signature(given_headers).should == exp_signature
    end

    it "should generate correct signatures 2" do
      given_headers = File.new(DIR + 'b.head').read
      exp_signature = File.new(DIR + 'b.sig').read
      Service.generate_signature(given_headers).should == exp_signature
    end
  end
end

# module Digipost::Api
# end