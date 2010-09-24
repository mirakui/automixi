# vim:fileencoding=utf-8
require 'bundler/setup'
require 'nokogiri'
require 'open-uri'

class Fetcher
end

class TwitPicFetcher < Fetcher
  def fetch
    feed_uri = 'http://twitpic.com/photos/mirakui/feed.rss'
    doc = Nokogiri::XML(open(feed_uri))
    (doc / 'item description').map do |item|
      if item.content =~ /^.*?:\s+(.*)<br>.*href=".+?".*src="(.+?)"/
        puts "base:  #{$1}"
        h = tokenize($1)
        #h = wakachi $1
        puts "title: #{h[:title]}"
        puts "body:  #{h[:body]}"
        puts "---"
        {:title => $1, :body => $1, :photos => [$2]}
      end
    end
  end

  def tokenize(str)
    tokenize_regex(str) || {:title => str, :body => str}
  end

  def tokenize_regex(str)
    sym_default = /[,、.。 　]/
    sym_ex      = /[？！\?!…]/
    sym_all    = /(?:#{sym_default}|#{sym_ex})/
    if str =~ /^(.+?)(#{sym_all}+)(.*)$/
      title = $1
      s = $2
      body = $3
      return nil unless body.to_s.length > 0
      title += s if s =~ /#{sym_ex}+/
      body.gsub!(/#{sym_all}+/, "\\&\n")
      return {:title => title, :body => body}
    end
    return nil
  end
end

def main
  t = TwitPicFetcher.new
  t.fetch
end


#__END__
main

