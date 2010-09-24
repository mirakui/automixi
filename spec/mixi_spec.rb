# vim:fileencoding=utf-8
require 'spec_helper'
require 'digest/sha1'
require 'ruby-debug'
require 'kconv'

describe Mixi do
  describe "login" do
    before do
      @mixi = Mixi.new
      pit = Pit.get 'mixitest', :require => {'email' => '', 'password' => ''}
      @mixi.login pit['email'], pit['password']
    end

    it 'write_diary' do
      sha1 = Digest::SHA1.hexdigest(rand.to_s)[0,8]
      title = "テスト（#{sha1}）"
      body  = "こんにちはこんにちは（#{sha1}）"
      @mixi.write_diary(title, body)
      @mixi.mech.get '/list_diary.pl'
      res = Kconv.toutf8(@mixi.mech.page.body)
      res.should match(/#{title}/)
      res.should match(/#{body}/)
    end

    it 'write_voice' do
      sha1 = Digest::SHA1.hexdigest(rand.to_s)[0,8]
      body  = "テストです（#{sha1}）"
      @mixi.write_voice(body)
      @mixi.mech.get '/recent_voice.pl'
      res = Kconv.toutf8(@mixi.mech.page.body)
      res.should match(/#{body}/)
    end
  end
end
