require 'net/http'
require 'cgi'
require 'rest-client'
require 'alipay/version'
require 'alipay/utils'
require 'alipay/sign'
require 'alipay/sign/md5'
require 'alipay/sign/rsa'
require 'alipay/sign/dsa'
require 'alipay/service'
require 'alipay/notify'
require 'alipay/wap/service'
require 'alipay/wap/notify'
require 'alipay/wap/sign'
require 'alipay/mobile/service'
require 'alipay/mobile/sign'
require 'alipay/open/service'
require 'alipay/open/sign'

module Alipay
  @debug_mode = true
  @sign_type = 'MD5'

  class << self
    attr_accessor :pid, :key, :sign_type, :debug_mode
    attr_accessor :open_pid, :rsa_private_key_file, :rsa_public_key_file

    def debug_mode?
      !!@debug_mode
    end
  end
end
