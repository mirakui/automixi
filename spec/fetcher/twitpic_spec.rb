require 'spec_helper'

describe Fetcher::Twitpic do
  it "fetch" do
    fetched = Fetcher::Twitpic.fetch :user => 'mirakui'
    fetched.should have_at_least(2).items
    fetched.each do |f|
      f[:title].should be_a(String)
      f[:body].should be_a(String)
      f[:id].should be_a(String)
      f[:photos].should have_exactly(1).photo
      f[:photos].first.should be_a(URI)
    end
  end

  it "fetch with last_id" do
    fetched = Fetcher::Twitpic.fetch :user => 'mirakui'
    length = fetched.length
    fetched.should have_at_least(10).items
    last_id = fetched[3][:id]
    fetched = Fetcher::Twitpic.fetch :user => 'mirakui', :last_id => last_id
    fetched.should have_exactly(length - 4).items
  end
end
