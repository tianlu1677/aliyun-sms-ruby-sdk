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
            'AccessKeyId'       => configuration.access_key_id,
            'Action'            => configuration.action,
            'Format'            => configuration.format,
            'ParamString'       => message_param,
            'RecNum'            => phone_number,
            'RegionId'          => configuration.region_id,
            'SignName'          => configuration.sign_name,
            'SignatureMethod'   => configuration.signature_method,
            'SignatureNonce'    => seed_signature_nonce,
            'SignatureVersion'  => configuration.signature_version,
            'TemplateCode'      => template_code,
            'Timestamp'         => seed_timestamp,
            'Version'           => configuration.sms_version,
          }
        end

        
        def send(template_code, phone_number, params)
          begin
            uri = URI("https://sms.aliyuncs.com")
            header = {"Content-Type": "application/x-www-form-urlencoded"}
            http = Net::HTTP.new(uri.host, uri.port)
            req = Net::HTTP::Post.new(uri.request_uri, header)
            req.body = sign_result(configuration.access_key_secret, params)
            response = http.request(req)
            if response.status == 200 || response.status == 201
              {code: 200, body: response.body, msg: "Success"}
            else
              {code: response.body, body: '', msg: "A Error"}
            end
          rescue => e
            puts "errors #{e}"
          end
        end

        def sign_result(key_secret, params)
          body_data = "Signature=" + sign(key_secret, params) + '&' + query_string(params)
        end

        def sign(key_secret, params)
          signature = 'POST' + '&' + encode('/') + '&' + encode(URI.encode_www_form(params))
          sign = Base64.encode64(OpenSSL::HMAC.digest('sha1', "#{key_secret}&", signature))
          encode(sign.chomp)
        end

        private
        def encode(input)
          ERB::Util.url_encode(input)
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
