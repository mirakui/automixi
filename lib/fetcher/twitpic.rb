# vim:fileencoding=utf-8
require 'uri'
require 'nokogiri'
require 'open-uri'

module Fetcher
  class Twitpic
    def self.fetch(opts={})
      feed_uri = "http://twitpic.com/photos/#{opts[:user]||'mirakui'}/feed.rss"
      doc = Nokogiri::XML(open(feed_uri))
      (doc / 'item description').map do |item|
        if item.content =~ /^.*?:\s+(.*)<br>.*href=".+?".*src="(.+?\/(\w+)\.jpg)"/
          id = $3
          photo_url = URI.parse($2)
          h = tokenize($1)
          h.merge :photos => [photo_url], :id => id
        end
      end.take_while {|item| item[:id] != opts[:last_id]}.reverse
    end

    def self.tokenize(str)
      tokenize_regex(str) || {:title => str, :body => str}
    end

    def self.tokenize_regex(str)
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
end
