require "spec_helper"
require "msngr"

describe Msngr do

  it "should instantiate an instance of Msngr::Messenger" do
    Msngr.new(mock).class.should == Msngr::Messenger
  end
end

