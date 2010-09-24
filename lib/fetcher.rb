require 'rubygems'
require 'bundler/setup'
require 'nokogiri'
require 'open-uri'
require 'MeCab'

class Fetcher
end

class TwitPicFetcher < Fetcher
  def fetch
    feed_uri = 'http://twitpic.com/photos/mirakui/feed.rss'
    doc = Nokogiri::XML(open(feed_uri))
    (doc / 'item description').map do |item|
      if item.content =~ /^.*?:\s+(.*)<br>.*href=".+?".*src="(.+?)"/
        puts "base:  #{$1}"
        h = wakachi $1
        puts "title: #{h[:title]}"
        puts "body:  #{h[:body]}"
        puts "---"
        {:title => $1, :body => $1, :photos => [$2]}
      end
    end
  end

  def wakachi(str)
    mecab = MeCab::Tagger.new()
    node = mecab.parseToNode(str)
    phase = 0
    title = ''
    body = ''
    while node do
      features = node.feature.split(',')
      case phase
      when 1
        case features[0]
        when '名詞'
          title += node.surface
        when '助詞'
          title += node.surface
        else
          phase += 1
          body += node.surface
        end
      when 2
        body += node.surface
      end
      puts "#{node.surface}\t>>#{node.feature}"
      node = node.next
      phase += 1 if phase == 0
    end
    {:title => title, :body => body}
  end

end

def main
  t = TwitPicFetcher.new
  t.fetch
end


#__END__
main

