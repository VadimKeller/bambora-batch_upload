module Bambora::BatchUpload
  class BatchUploadError < StandardError
    attr_reader :code, :category, :message, :http_code
    def initialize args
      @code      = args[:code]
      @category  = args[:category] 
      @message   = args[:message]
      @http_code = args[:http_code]
    end
    def to_s
      "Code: #{code}, Error Category: #{category}, Message: #{message}, HTTP response: #{http_code}"
    end
  end
  class ConnectionError < StandardError
  end
end
