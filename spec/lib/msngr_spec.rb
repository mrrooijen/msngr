require "spec_helper"
require "msngr"

describe Msngr do

  it "should instantiate an instance of Msngr::Messenger" do
    expect(Msngr.new(double).class).to eq(Msngr::Messenger)
  end
end

