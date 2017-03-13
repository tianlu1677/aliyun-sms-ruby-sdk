# require 'aliyun/sms'
# require 'minitest/autorun'
require "./test_helper"

class TestPhoneCode < Minitest::Test
  def setup
    Aliyun::Sms::PhoneCode.configure do |config|
      config.access_key_secret = 'testsecret'
      config.access_key_id = 'testid'
      config.action = 'SingleSendSms'
      config.format = 'XML'
      config.region_id = 'cn-hangzhou'
      config.sign_name = '标签测试'
      config.signature_method = 'HMAC-SHA1'
      config.signature_version = '1.0'
      config.sms_version = '2016-09-27'
    end
  end

  def test_get_sign
    params_input = {
        'AccessKeyId' => 'testid',
        'Action' => 'SingleSendSms',
        'Format' => 'XML',
        'ParamString' => '{"name":"d","name1":"d"}',
        'RecNum' => '13098765432',
        'RegionId' => 'cn-hangzhou',
        'SignName' => '标签测试',
        'SignatureMethod' => 'HMAC-SHA1',
        'SignatureNonce' => '9e030f6b-03a2-40f0-a6ba-157d44532fd0',
        'SignatureVersion' => '1.0',
        'TemplateCode' => 'SMS_1650053',
        'Timestamp' => '2016-10-20T05:37:52Z',
        'Version' => '2016-09-27',
      }
      key = 'testsecret'
      spect_output = 'ka8PDlV7S9sYqxEMRnmlBv%2FDoAE%3D'
      assert_equal spect_output, Aliyun::Sms::PhoneCode.sign(key, params_input)
  end

  def test_post_body_data
    params_input = {
        'AccessKeyId' => 'testid',
        'Action' => 'SingleSendSms',
        'Format' => 'XML',
        'ParamString' => '{"name":"d","name1":"d"}',
        'RecNum' => '13098765432',
        'RegionId' => 'cn-hangzhou',
        'SignName' => '标签测试',
        'SignatureMethod' => 'HMAC-SHA1',
        'SignatureNonce' => '9e030f6b-03a2-40f0-a6ba-157d44532fd0',
        'SignatureVersion' => '1.0',
        'TemplateCode' => 'SMS_1650053',
        'Timestamp' => '2016-10-20T05:37:52Z',
        'Version' => '2016-09-27',
      }
    key = 'testsecret'

    spect_output = 'Signature=ka8PDlV7S9sYqxEMRnmlBv%2FDoAE%3D&AccessKeyId=testid&Action=SingleSendSms&Format=XML&ParamString={"name":"d","name1":"d"}&RecNum=13098765432&RegionId=cn-hangzhou&SignName=标签测试&SignatureMethod=HMAC-SHA1&SignatureNonce=9e030f6b-03a2-40f0-a6ba-157d44532fd0&SignatureVersion=1.0&TemplateCode=SMS_1650053&Timestamp=2016-10-20T05:37:52Z&Version=2016-09-27'

    assert_equal spect_output, Aliyun::Sms::PhoneCode.sign_result(key, params_input)
  end

end