# vim:fileencoding=utf-8
require 'spec_helper'

describe Mixi do
  describe "login" do
    before do
      @mixi = Mixi.new
      pit = Pit.get 'mixitest', :require => {'email' => '', 'password' => ''}
      @mixi.login pit['email'], pit['password']
    end

    it 'write_diary' do
      @mixi.write_diary('test', 'テスト')
    end
  end
end
