module QiniuUtility
  class ObjectStorage
    def initialize(access_key, secret_key)
      Qiniu.establish_connection!(access_key: access_key, secret_key: secret_key)
    end

    def generate_upload_token(bucket)
      Qiniu::Auth.generate_uptoken Qiniu::Auth::PutPolicy.new(bucket)
    end

    def generate_access_token(url)
      Qiniu::Auth.generate_acctoken(url)
    end

    def fetch_from_url(original_url, bucket)
      QiniuUtility.logger.info "QiniuUtility::ObjectStorage fetch_from_url reqt: #{original_url}"
      api_url = "http://iovip.qbox.me/fetch/#{Base64.urlsafe_encode64(original_url)}/to/#{Base64.urlsafe_encode64(bucket)}"
      resp = Faraday.post api_url, {}, {Authorization: "QBox #{generate_access_token(api_url)}"}
      QiniuUtility.logger.info "QiniuUtility::ObjectStorage fetch_from_url resp(#{resp.status}): #{resp.body}"
      JSON.load(resp.body)["key"]
    end
  end
end
