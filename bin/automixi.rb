require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'config', 'initializer')

class AutoMixi
  def initialize(opts={})
    @mixi = Mixi.new
    @pit = Pit.get(opts[:pit] || 'mixitest', :require => {'email' => '', 'password' => ''})
  end

  def run
    @mixi.login @pit['email'], @pit['password']
    fetch_all
  end

  def fetch_all
    fetch_twitpic
  end

  def fetch_twitpic
    log = FetcherLog.first(:name => 'twitpic')
    last_id = log ? log.last_id : nil
    entries = Fetcher::Twitpic.fetch :user => 'mirakui', :last_id => last_id
    entries.each do |entry|
      @mixi.write_diary(entry[:title], entry[:body], :photos => entry[:photos])
      break
    end
  end
end

def main
  ApplicationConfig.env = 'development'

  mixi = AutoMixi.new
  mixi.run
end

main
