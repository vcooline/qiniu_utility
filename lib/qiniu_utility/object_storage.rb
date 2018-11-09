module QiniuUtility
  class ObjectStorage
    def initialize(access_key, secret_key)
      Qiniu.establish_connection!(access_key: access_key, secret_key: secret_key)
    end

    def generate_upload_token(bucket)
      Qiniu::Auth.generate_uptoken Qiniu::Auth::PutPolicy.new(bucket)
    end
  end
end

