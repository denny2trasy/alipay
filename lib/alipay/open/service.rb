module Alipay
  module Open
    module Service
      GATEWAY_URL = 'https://openapi.alipay.com/gateway.do'
      
      TRADE_PRECREATE_REQUIRED_PARAMS = %w( out_trade_no subject total_amount time_expire )
      # 扫描支付 － 预下单请求
      def self.trade_precreate(params, options = {})
        
        Alipay::Service.check_required_params(params, TRADE_PRECREATE_REQUIRED_PARAMS)

        base_params = {
          'app_id'        => Alipay.open_pid,
          'method'        => 'alipay.trade.precreate',
          'charset'       => 'UTF-8',
          'sign_type'     => 'RSA',
          'timestamp'     => options['timestamp'],
          'version'       => "1.0",
          'notify_url'    => options['notify_url']
        }

        sign = Alipay::Open::Sign.generate(base_params.merge({'biz_content' => params}))

        url = request_uri(base_params.merge({'sign' => sign}))

        post_params = post_params(params)

        execution_options = {
          :method => :post, 
          :url => url, 
          :payload => post_params, 
          :timeout => 10, 
          :open_timeout => 10, 
          headers: {content_type: "application/x-www-form-urlencoded", accept: :json, charset: "UTF-8"}
        }

        RestClient::Request.execute(execution_options) { |response, request, result|
          case result.code
          when "200"
            result = JSON.parse response
            puts "Result: #{result}"
            ali_res = result["alipay_trade_precreate_response"]
            code = ali_res["code"]
            puts "Code: #{code}"
            if code == "10000"
              return ali_res["qr_code"]
            else
              return nil
            end
          else
            return nil
          end
        }
      end

      def self.request_uri(params)
        pparams = params.map do |key, value|
          "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"
        end.join('&')
        return "#{GATEWAY_URL}?#{pparams}"
      end

      def self.post_params(biz_content) 
        "biz_content=#{CGI.escape(biz_content.to_json.to_s)}"
      end

      # String Params for sign
      def self.stringify_params(params)
        result = []
        params.sort.each do |key, value|
          if value.class == Hash
            result << "#{key.to_s}=#{value.to_json.to_s}"
          else
            result << "#{key.to_s}=#{value}"
          end
        end
        result.join("&")
      end

      def self.rsa_sign for_sign_string

        #读取私钥文件
        rsa_private_key_file = File.read(Alipay.rsa_private_key_file)
        #转换为openssl密钥
        openssl_key = OpenSSL::PKey::RSA.new rsa_private_key_file
        #使用openssl方法进行sha1签名digest(不能用sha256)
        puts " ++++ Openssl Key = #{openssl_key}"
        digest = OpenSSL::Digest::SHA1.new
        signature = openssl_key.sign digest, for_sign_string

        puts " ++++ Digest = #{digest}"
        puts " ++++ Signature no encode = #{signature}"

        #base64编码
        signature = Base64.encode64(signature)

        puts " ++++ Signature encoded = #{signature}"
        return signature.gsub("\n","")
      end

    end
  end
end