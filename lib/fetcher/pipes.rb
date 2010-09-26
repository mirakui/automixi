# vim:fileencoding=utf-8
require 'uri'
require 'open-uri'
require 'json'
require 'active_support/core_ext/object/blank'
require 'htmlentities'

include Util

class Fetcher
  class Pipes
    def self.fetch(opts={})
      json = JSON.parse open(opts[:json_url]).read
      json["value"]["items"].map do |item|
        t = {
          :title => item["title"],
          :body => item["description"],
          :id => item["guid"]
        }
        if t[:title] == t[:body] || t[:title].blank? || t[:body].blank?
          str = t[:title].presence || t[:body].presence
          t.merge! tokenize(str)
        end
        photo_url = item["media:content"].presence{|m| m["url"]}
        t["photos"] = [URI.parse(photo_url)] if photo_url =~ /\.jpg/
        t
      end.take_while {|item| item[:id] != opts[:last_id]}.reverse
    end

    def self.tokenize(str)
      tokenize_regex(str) || {:title => str, :body => str}
    end

    def self.tokenize_regex(str)
      sym_default = /[,、.。\s　]/
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
