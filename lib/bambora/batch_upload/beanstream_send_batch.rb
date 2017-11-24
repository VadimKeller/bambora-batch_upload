require 'base64'
require 'json'
require 'curb'

module Bambora::BatchUpload
  class BeanstreamSendBatch

    attr_accessor :file_path
    attr_accessor :process_date
    attr_accessor :process_now
    attr_accessor :failure_message

    def initialize(file_path, process_date, process_now)
      @file_path    = file_path
      @process_date = process_date
      @process_now  = process_now
    end
  
    BATCH_PROCESS_SUCCESS      = 1
     
    def send
      c = Curl::Easy.new(batch_uploads_api_url) do |curl| 
        curl.headers["Authorization"] = "Passcode #{encoded_pass_code}"
      end
      c.multipart_form_post  = true
      c.http_post(criteria_content,file_content)
      response    = JSON.parse(c.body)
      if response["code"] == BATCH_PROCESS_SUCCESS 
        response["batch_id"] 
      else 
        @failure_message = "Message: #{response["message"]}, Date: #{process_date}"
        nil
      end
    end
  
    def criteria_content
      criteria_content  = Curl::PostField.content("criteria",
                                                  "{'process_date':#{process_date_formatted},'process_now':#{process_now} }",
                                                  "application/json")
    end
  
    def file_content
      file_content      = Curl::PostField.file("file1",file_path)
    end
  
  
    def process_date_formatted
      process_date.to_s.gsub("-","")
    end
  
    def encoded_pass_code
      Base64.strict_encode64("#{merchant_id}:#{batch_uploads_api_key}")
    end
  
    def merchant_id
      Bambora::BatchUpload.merchant_id
    end
  
    def batch_uploads_api_key
      Bambora::BatchUpload.batch_upload_api_key
    end
  
    def batch_uploads_api_url
      Bambora::BatchUpload.get_batch_upload_api_url
    end
  
  end
end
