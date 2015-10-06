module Alipay
  module Open
    module Service
      GATEWAY_URL = 'https://openapi.alipay.com/gateway.do'
      
      TRADE_PRECREATE_REQUIRED_PARAMS = %w( out_trade_no subject total_amount time_expire )
      # 扫描支付 － 预下单请求
      def self.trade_precreate(params, options = {})
        
        Alipay::Service.check_required_params(params, TRADE_PRECREATE_REQUIRED_PARAMS)

        puts "+++++ Params= #{params}"

        full_params = {
          'app_id'        => Alipay.open_pid,
          'method'        => 'alipay.trade.precreate',
          'charset'       => 'UTF-8',
          'sign_type'     => 'RSA',
          'timestamp'     =>  "#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}",
          'version'       => "1.0",
          'notify_url'    => options['notify_url']
        }.merge('biz_content' => params)

        sign = Alipay::Open::Sign.generate(full_params)

        puts "+++++ Sign = #{sign}"

        url = request_uri(full_params.merge('sign' => sign))

        puts "+++++ URL = #{url}"

        post_params = post_params(params)

        puts "+++++ Post Params = #{post_params}"

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

    end
  end
end