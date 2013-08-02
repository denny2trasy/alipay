require 'test_helper'

class Alipay::NotifyTest < Test::Unit::TestCase
  def setup
    @options = {
      :notify_id => '1234'
    }
    @options.merge!(:sign_type => 'MD5', :sign => Alipay::Sign.generate(@options))
  end

  def test_verify_notify_when_true
    FakeWeb.register_uri(:get, "http://notify.alipay.com/trade/notify_query.do?partner=#{Alipay.pid}&notify_id=1234", :body => "true")
    assert Alipay::Notify.verify?(@options)
  end

  def test_verify_notify_when_false
    FakeWeb.register_uri(:get, "http://notify.alipay.com/trade/notify_query.do?partner=#{Alipay.pid}&notify_id=1234", :body => "false")
    assert !Alipay::Notify.verify?(@options)
  end
end