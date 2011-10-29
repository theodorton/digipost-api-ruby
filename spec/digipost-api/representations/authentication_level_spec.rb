require 'rspec'

module Digipost::Api::Representations
  describe AuthenticationLevel do
    it "should have a 'password' level for 2" do
      AuthenticationLevel::LEVELS[2].should == :password
    end
    
    it "should have a 'two factor' level for 3" do
      AuthenticationLevel::LEVELS[3].should == :two_factor
    end
  end
end