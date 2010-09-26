# vim:fileencoding=utf-8
require 'bundler/setup'
require 'mechanize'
require 'pit'
require 'ruby-debug'
require 'logger'
require 'tempfile'
require 'open-uri'

include Util

class Mechanize
  class Form
    alias _orig_param_to_multipart param_to_multipart
    def param_to_multipart(name, value)
      _orig_param_to_multipart(name, value).force_encoding("ascii-8bit")
    end
  end
end

class MixiError < Exception; end

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
    expect_status 200
    form
  end

  def get(path)
    logger.debug "try to fetch: #{path}"
    @mech.get "#{MIXI_URL}#{path}"
    logger.debug "status: #{@mech.page.code}"
    expect_status 200

    %w(#errorArea .messageAlert).each do |e|
      error = @mech.page.at(e).presence {|a| a.inner_text.strip}
      raise MixiError, error if error.present?
    end
    @mech.page
  end

  def write_diary(title, body, opts={})
    get "/add_diary.pl?id=#{@user_id}"
    @mech.page.form_with(:name => 'diary') do |f|
      puts @mech.page.body unless f
      f['diary_title'] = normalize(title)
      f['diary_body'] = normalize(body)
      (opts[:photos] || [])[0..2].each_with_index do |photo, i|
        photo = uri_to_tempfile(photo) if photo.is_a?(URI)
        f.file_upload_with(:name => "photo#{i+1}") do |up|
          up.file_name = photo
        end
      end
      submit f
    end
    @mech.page.form_with(:action => 'add_diary.pl') do |f|
      submit f
    end
  end

  def write_voice(body)
    get "/recent_voice.pl"
    @mech.page.form_with(:action => "add_voice.pl") do |f|
      f['body'] = body
      submit f
    end
  end

  def expect_status(status)
    raise "error(#{@mech.page.code}) url: #{@mech.page.uri}" unless @mech.page.code.to_i == status.to_i
  end

  def coder
    @coder ||= HTMLEntities.new
  end

  def encode(str)
    coder.encode(str, :decimal)
  end

  def decode(str)
    coder.decode(str)
  end

  def normalize(str)
    str = decode(str)
    str.encode("euc-jp")
    str
  rescue
    encode(encode(encode(str)))
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end

  def logger=(l)
    @logger = l
  end

  def uri_to_tempfile(uri)
    tempfile_path = ApplicationConfig.root.join("tmp", uri.path.split("/").last)
    open(tempfile_path, "w") do |f|
      f.write uri.read
    end
    logger.debug "download #{uri} to #{tempfile_path}"
    tempfile_path.to_s
  end
end

__END__

def main
  mixi = Mixi.new

  pit = Pit.get 'mixi', :require => {'email' => '', 'password' => ''}
  mixi.login pit['email'], pit['password']
  mixi.write_diary('test', 'テスト')
end

main

