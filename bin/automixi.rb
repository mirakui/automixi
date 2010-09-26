require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'config', 'initializer')

class AutoMixi
  def initialize(opts={})
    @mixi = Mixi.new
    @pit = Pit.get(opts[:pit] || 'mixitest', :require => {'email' => '', 'password' => ''})
  end

  def run
    @mixi.login @pit['email'], @pit['password']
    fetch_pipes
  end

  def fetch_pipes
    log = FetcherLog.first(:name => 'pipes')
    log = nil
    if log
      last_id = log.last_id
    else
      log = FetcherLog.new(:name => 'pipes')
      last_id = nil
    end
    entries = Fetcher::Pipes.fetch :json_url => "http://pipes.yahoo.com/pipes/pipe.run?_id=96ecead17fb7ae0881e8adf9d7bebe55&_render=json&#{Time.now.to_i}", :last_id => last_id
    entries.each do |entry|
      p entry
      @mixi.write_diary(entry[:title], entry[:body], :photos => entry[:photos])
      log.last_id = entry[:id]
      log.save
    end
  end
end

def main
  ApplicationConfig.env = 'development'

  mixi = AutoMixi.new
  mixi.run
end

main
