require "qiniu"
require "active_support/all"
require "qiniu_utility/version"
require "qiniu_utility/object_storage"

module QiniuUtility
  def self.logger
    @logger ||= defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
  end
end
