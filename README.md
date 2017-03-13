# 阿里云短信服务
这里借鉴了 [aliyun-sms](https://github.com/VICTOR-LUO-F/aliyun-sms) 主要的签名算法。
[官网短信发送说明](https://help.aliyun.com/document_detail/44362.html?spm=5176.doc44364.2.1.A5oJFn)
这里没有依赖第三方 Gem,适合低版本的ruby使用。

## 安装
在应用的 Gemfile 文件中添加 Ruby Gems 安装源:

```ruby
gem 'aliyun-sms-ruby-sdk'
```

应用的根目录下运行:

    $ bundle

或者直接在ruby下安装

    $ gem install aliyun-sms-ruby-sdk

## 使用
### 1. 创建配置文件在 `config/initializers/aliyun-sms-ruby-sdk.rb`

```ruby
Aliyun::Sms::PhoneCode.configure do |config|
      config.access_key_secret = ACCESS_KEY_SECRET # 阿里云接入密钥，在阿里云控制台申请
      config.access_key_id = ACCESS_KEY_ID         # 阿里云接入 ID, 
      config.sign_name = SIGN_NAME                 # 短信签名，在阿里云申请开通短信服务时申请获取在阿里云控制台申请
      
      #config.action = 'SingleSendSms'              # 默认设置，如果没有特殊需要，可以不改
      #config.format = 'JSON'                       # 短信推送返回信息格式，可以填写 'JSON'或者'XML'
      #config.region_id = 'cn-hangzhou'             # 默认设置，如果没有特殊需要，可以不改      
      
      #config.signature_method = 'HMAC-SHA1'        # 加密算法，默认设置，不用修改
      #config.signature_version = '1.0'             # 签名版本，默认设置，不用修改
      #config.sms_version = '2016-09-27'            # 服务版本，默认设置，不用修改
  end

```

### 第二步调用方法发送短信

```ruby
$ Aliyun::Sms::PhoneCode.send(template_code, phone_number, param_string)
```

参数说明：
1. phone_number: 接收短信的手机号，必须为字符型，例如 '1234567890'；
2. template_code: 短信模版代码，必须为字符型，申请开通短信服务后，由阿里云提供，例如 'SMS_12345678'；
3. para_string: 请求字符串，向短信模版提供参数，必须为字符型的json格式，例如 '{"customer": "username"}'。

在程序中可以先用 HASH 组织 param_string 内容，再使用 to_json 方法转换为 json 格式字符串，例如：

```ruby
phone_number = '1234567890'
template_code = 'SMS_12345678'
param_string = {'customer' => 'username'}.to_json
Aliyun::Sms::PhoneCode.send(template_code, phone_number, param_string)
```

## 测试
在根目录下

```ruby
 ruby -Ilib:test test/aliyun/sms/test_phone_code.rb
```
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/aliyun-sms-ruby-sdk. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

