# encoding: utf-8
module Alipay
  module Open
    module Sign
    
      def self.generate(params)
        for_sign_string = Utils.stringify_keys_with_hash_value(params)

        puts "++++ String Params = #{for_sign_string}"

        #读取私钥文件
        rsa_private_key_file = File.read(Alipay.rsa_private_key_file)
        #转换为openssl密钥
        # openssl_key = OpenSSL::PKey::RSA.new rsa_private_key_file
        # puts " +++++ Openssl Key = #{openssl_key}"

        rsa = OpenSSL::PKey::RSA.new(rsa_private_key_file)
        puts " +++++ Openssl Key = #{rsa}"
        signature = rsa.sign 'sha1', for_sign_string

        puts " ++++ Signature no encode = #{signature}"

        signature = Base64.strict_encode64(signature)

        puts " ++++ Signature encoded = #{signature}"
        
        return signature.gsub("\n","")
        
        # #使用openssl方法进行sha1签名digest(不能用sha256)
        # digest = OpenSSL::Digest::SHA1.new
        # signature = openssl_key.sign digest, for_sign_string

        # puts " ++++ Digest = #{digest}"
        # puts " ++++ Signature no encode = #{signature}"

        # #base64编码
        # signature = Base64.encode64(signature)

        # puts " ++++ Signature encoded = #{signature}"

        # return signature.gsub("\n","")
      end

    end
  end
end