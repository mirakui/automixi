require 'rubygems'
require 'bundler/setup'
require 'mechanize'
require 'pit'
require 'ruby-debug'
require 'logger'

class Mixi
  MIXI_URL = 'http://mixi.jp'
  attr :mech
  attr :logger

  def initialize
    @user_id = nil
    @mech = Mechanize.new
  end

  def login(email, password)
    get '/'
    @mech.page.form_with(:name => 'login_form') do |f|
      f['email'] = email
      f['password'] = password
      submit f
    end
    get '/home.pl'
    @mech.page.link_with(:href => /show_profile.pl/) do |link|
      @user_id = link.href[/\d+/].to_i
    end
  end

  def submit(form)
    logger.debug "try to submit: #{@mech.page.uri}"
    form.submit
    logger.debug "status: #{@mech.page.code}"
    assert_status 200
    form
  end

  def get(path)
    logger.debug "try to fetch: #{path}"
    @mech.get "#{MIXI_URL}#{path}"
    logger.debug "status: #{@mech.page.code}"
    assert_status 200
    @mech.page
  end

  def write_diary(title, body)
    get "/add_diary.pl?id=#{@user_id}"
    @mech.page.form_with(:name => 'diary') do |f|
      f['diary_title'] = title
      f['diary_body'] = body
      submit f
    end
    @mech.page.form_with(:action => 'add_diary.pl') do |f|
      submit f
    end
  end

  def assert_status(status)
    raise "error(#{@mech.page.code}) url: #{@mech.page.uri}" unless @mech.page.code.to_i == status.to_i
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end

  def logger=(l)
    @logger = l
  end
end


def main
  mixi = Mixi.new

  pit = Pit.get 'mixi', :require => {'email' => '', 'password' => ''}
  mixi.login pit['email'], pit['password']
  mixi.write_diary('test', 'テスト')
end

main

