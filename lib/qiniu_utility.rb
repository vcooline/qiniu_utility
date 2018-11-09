require "active_support/all"
require "qiniu_utility/version"

module QiniuUtility
  def self.logger
    @logger ||= defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
  end
end
