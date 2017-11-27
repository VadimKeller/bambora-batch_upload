require_relative 'beanstream_send_batch'
require_relative 'exceptions'

module Bambora::BatchUpload
  class SendSingleBatch

    attr_accessor :file_path
    attr_accessor :process_date
    
    def initialize(file_path,process_date) 
      @file_path    = file_path
      @process_date = process_date
    end
  
    def call
      begin
        service          = BeanstreamSendBatch.new(file_path,
                                                   process_date,
                                                   process_now)
        batch_id         = service.send
        unless batch_id.nil?
          yield(batch_id) if block_given? 
        end
      rescue BatchUploadError #reraise error
        raise
      rescue JSON::ParserError => err
        raise ConnectionError, "JSON parse Error: #{err.message}"
      rescue => err #most likely api connection error
        raise ConnectionError, "#{err.class}: #{err.message}"
      end
    end
  
    private
  
    def process_now
      if process_date
        0
      else
        1
      end
    end
  
  end
end
