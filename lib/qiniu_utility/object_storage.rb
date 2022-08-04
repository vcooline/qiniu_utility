module QiniuUtility
  class ObjectStorage
    def initialize(access_key, secret_key, multi_region: false)
      Qiniu.establish_connection!(access_key:, secret_key:, multi_region:)
    end

    def generate_upload_token(bucket, options = {})
      put_policy = Qiniu::Auth::PutPolicy.new(bucket)
      options.each { |k, v| put_policy.send("#{k}=", v) if put_policy.respond_to?(k) }
      Qiniu::Auth.generate_uptoken put_policy
    end

    def generate_access_token(url)
      Qiniu::Auth.generate_acctoken(url)
    end

    def stat(bucket, key)
      Qiniu.stat(bucket, key)
    end

    def change_meta_data(bucket, key, meta_key, meta_value)
      encoded_entry_uri = Base64.urlsafe_encode64 [bucket, key].join(":")
      encoded_meta_value = Base64.urlsafe_encode64 meta_value
      Qiniu::HTTP.management_post "https://rs.qbox.me/chgm/#{encoded_entry_uri}/x-qn-meta-#{meta_key}/#{encoded_meta_value}"
    end

    def fetch_from_url(original_url, bucket, download_url: "http://iovip.qbox.me")
      QiniuUtility.logger.info "QiniuUtility::ObjectStorage fetch_from_url reqt: #{original_url}"
      api_url = "#{download_url}/fetch/#{Base64.urlsafe_encode64(original_url)}/to/#{Base64.urlsafe_encode64(bucket)}"
      resp = Faraday.post api_url, {}, {Authorization: "QBox #{generate_access_token(api_url)}"}
      QiniuUtility.logger.info "QiniuUtility::ObjectStorage fetch_from_url resp(#{resp.status}): #{resp.body}"
      JSON.load(resp.body)["key"]
    end

    def list(bucket, limit=100)
     code, result, response_headers, s, d = Qiniu::Storage.list(Qiniu::Storage::ListPolicy.new(bucket, limit))
     QiniuUtility.logger.info "QiniuUtility::ObjectStorage list #{bucket} resp(#{code}): #{result['error'] || {items_count: result["items"].count}.to_json}; #{response_headers.to_json}; #{s.to_json}; #{d.to_json}"
     result["items"]
    end

    def change_file_type(bucket, key, type, base_url: "http://rs.qiniu.com")
      QiniuUtility.logger.info "#{self.class.name} change_type reqt: #{bucket}:#{key} to #{type}"
      encoded_entry_uri = Base64.urlsafe_encode64("#{bucket}:#{key}")
      api_url = "#{base_url}/chtype/#{encoded_entry_uri}/type/#{type}"
      resp = Faraday.post api_url, {}, { Authorization: "QBox #{generate_access_token(api_url)}" }
      QiniuUtility.logger.info "#{self.class.name} change_type resp(#{resp.status}): #{resp.body.squish}"
    end

    def delete(bucket, key)
      code, result, response_headers = Qiniu::Storage.delete(bucket, key)
      QiniuUtility.logger.info "QiniuUtility::ObjectStorage delete #{bucket} #{key} resp(#{code}): #{result.to_json}; #{response_headers.to_json}"
      result
    end

    def authenticate_callback_request(auth_str, url, body)
      Qiniu::Auth.authenticate_callback_request(auth_str.to_s, url.to_s, body.to_s)
    end

  end
end
