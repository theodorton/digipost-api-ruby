require_relative '../../lib/digipost-api'
require 'rspec'
require 'openssl'
require 'base64'

DIR = 'spec/digipost-api/examples/'

module Digipost::Api
  describe Service do
    before(:all) do
      Service.configure(179069, '', File.new('spec/digipost-api/private_key').read)
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