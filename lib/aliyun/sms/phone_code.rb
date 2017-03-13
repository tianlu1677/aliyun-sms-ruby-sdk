require 'aliyun/version'
require 'net/http'
require 'openssl'
require 'base64'
require 'uri'
require 'erb'
include ERB::Util

module Aliyun
	module Sms
		class PhoneCode
			attr_accessor :access_key_secret, 
										:access_key_id, 
										:action,
										:format,
										:region_id,
										:sign_name, 
										:signature_method, 
										:signature_version, 
										:sms_version
			def initialize
				@access_key_secret = ''
        @access_key_id = ''
        @sign_name = ''
        @action ||= 'SingleSendSms'
        @format ||= 'JSON' 
        @region_id ||= 'cn-hangzhou' 
        @signature_method ||= 'HMAC-SHA1'
        @signature_version ||= '1.0'
        @sms_version ||= '2016-09-27' 
			end

			class << self
				attr_writer :configuration

				def configuration
					@configuration ||= PhoneCode.new
				end

				def configure
					yield(configuration)
				end

				def create_params(template_code, phone_number, content)
					sms_params ={
	          'AccessKeyId' 			=> configuration.access_key_id,
	          'Action' 						=> configuration.action,
	          'Format' 						=> configuration.format,
	          'ParamString' 			=> message_param,
	          'RecNum' 						=> phone_number,
	          'RegionId' 					=> configuration.region_id,
	          'SignName' 					=> configuration.sign_name,
	          'SignatureMethod' 	=> configuration.signature_method,
	          'SignatureNonce' 		=> seed_signature_nonce,
	          'SignatureVersion' 	=> configuration.signature_version,
	          'TemplateCode' 			=> template_code,
	          'Timestamp' 				=> seed_timestamp,
	          'Version' 					=> configuration.sms_version,
        	}
				end

				# TODO: 错误处理
				def send(template_code, phone_number, params)
					Net::HTTP.post( 
							URI("https://sms.aliyuncs.com"), 
							headers: {"Content-Type": "application/x-www-form-urlencoded"},
							body: sign_result(configuration.access_key_secret, params)
						)
				end

				def sign_result(key_secret, params)
					body_data = "Signature=" + sign(key_secret, params) + '&' + query_string(params)
				end

				def sign(key_secret, params)
					key = key_secret + '&'
					signature = 'POST' + '&' + encode('/') + '&' + canonicalized_query_string(params)
					sign = Base64.encode64("#{OpenSSL::HMAC.digest('sha1',key, signature)}")
					encode(sign.chomp)
				end

				private
				def encode(input)
					url_encode(input)
				end

				# 原生参数经过2次编码拼接成标准字符串
	      def canonicalized_query_string(params)
	        cqstring = ''
	        params.each do |key, value|
	          if cqstring.empty?
	            cqstring += "#{encode(key)}=#{encode(value)}"
	          else
	            cqstring += "&#{encode(key)}=#{encode(value)}"
	          end
	        end
	        return encode(cqstring)
	      end


      # 原生参数拼接成请求字符串
      def query_string(params)
        qstring = ''
        params.each do |key, value|
          if qstring.empty?
            qstring += "#{key}=#{value}"
          else
            qstring += "&#{key}=#{value}"
          end
        end
        return qstring
      end

			def seed_timestamp
				Time.now.utc.strftime("%FT%TZ")
			end

			def seed_signature_nonce
        Time.now.utc.strftime("%Y%m%d%H%M%S%L")
			end

			end
		end
	end
end

# https://sms.aliyuncs.com/?Action=SingleSendSms
# &SignName=阿里云短信服务
# &TemplateCode=SMS_1595010
# &RecNum=13011112222   
# &ParamString={"no":"123456"}
# &<公共请求参数>


# https://help.aliyun.com/document_detail/44363.html?spm=5176.doc44364.6.573.A5oJFn

# AccessKeyId=testid&Action=SingleSendSms&Format=XML
# &ParamString={"name":"d","name1":"d"}&RecNum=13098765432&RegionId=cn-hangzhou&SignName=标签测试&SignatureMethod=HMAC-SHA1&SignatureNonce=9e030f6b-03a2-40f0-a6ba-157d44532fd0&SignatureVersion=1.0&TemplateCode=SMS_1650053&Timestamp=2016-10-20T05:37:52Z&Version=2016-09-27
# 那么 StringToSign 就是：

# POST&%2F&AccessKeyId%3Dtestid%26Action%3DSingleSendSms%26Format%3DXML%26ParamString%3D%257B%2522name%2522%253A%2522d%2522%252C%2522name1%2522%253A%2522d%2522%257D%26RecNum%3D13098765432%26RegionId%3Dcn-hangzhou%26SignName%3D%25E6%25A0%2587%25E7%25AD%25BE%25E6%25B5%258B%25E8%25AF%2595%26SignatureMethod%3DHMAC-SHA1%26SignatureNonce%3D9e030f6b-03a2-40f0-a6ba-157d44532fd0%26SignatureVersion%3D1.0%26TemplateCode%3DSMS_1650053%26Timestamp%3D2016-10-20T05%253A37%253A52Z%26Version%3D2016-09-27