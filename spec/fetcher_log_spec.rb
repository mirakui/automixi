require 'spec_helper'

describe FetcherLog do
  it "should be able to do basic operations" do
    n = 3
    n.times do |i|
      f = FetcherLog.new
      f.name = "name#{i}"
      f.last_id = i.to_s
      f.save
    end

    n.times do |i|
      f = FetcherLog.first :name => "name#{i}"
      f.last_id.should == i.to_s
    end
  end
end
