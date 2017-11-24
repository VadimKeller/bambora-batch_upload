require_relative "batch_upload/version"
require_relative 'batch_upload/create_batch_file'
require_relative "batch_upload/send_single_batch"
require_relative "../extensions/date"

require 'ostruct'
require 'date'

module Bambora
  module BatchUpload
    @default_batch_upload_api_url  = "https://api.na.bambora.com/v1/batchpayments"
    @default_batch_file_path       = "/tmp"
    class << self
      #must be provided by user
      attr_accessor :merchant_id
      attr_accessor :batch_upload_api_key
      #optional
      attr_accessor :batch_file_path
      attr_accessor :batch_upload_api_url
      #file name
      attr_accessor :file_path
    end
    def self.do_upload(process_date=Date.next_business_day,&block)
      raise "Configure Merchant ID and Upload API key" unless config_complete 
      SendSingleBatch.new(file_path,process_date).call(&block) 
    end

    def self.create_file &block
      raise "provide a block" unless block_given?
      @file_path = CreateBatchFile.new(create_array(&block)).call
      raise "WTF, no file generated!!!" if @file_path.nil?
    end

    def self.get_batch_upload_api_url
      batch_upload_api_url || @default_batch_upload_api_url
    end

    def self.get_batch_file_path
      batch_file_path || @default_batch_file_path 
    end

    def self.configure &block
      raise ArgumentError unless block_given?
      yield(self)
    end

    def self.create_array &block
      reader = MakeArray.new
      yield(reader)
      reader.array
    end

    class MakeArray
      attr_accessor :array
      def initialize; @array=[]; end
      def push_into_file(params)
        validate_args params
        array << OpenStruct.new(txn_type:      params[:payment_type],
                                transit:       params[:transit_number].to_s,
                                institution:   params[:institution_number].to_s,
                                account:       params[:account_number].to_s,
                                amount:        params[:amount],
                                ref:           params[:reference].to_s,
                                recipient:     params[:recipient].to_s,
                                customer_code: params[:customer_code].to_s
                               )
      end
      private
      def validate_args params
        if params[:amount].nil?
          raise ArgumentError, "Must provide amount"       
        end
        unless params[:payment_type] == "D" || params[:payment_type] == "C"
          raise ArgumentError, "Must provide payment type: C (credit) or D (debit)" 
        end
        if params[:customer_code].nil? && (params[:transit_number] || 
                                           params[:institution_number] ||
                                           params[:account_number])
          raise ArgumentError, "Must either provide customer code or transit, institution, and account #s"
        end
      end
    end
    
    private

    def self.config_complete 
      merchant_id && batch_upload_api_key
    end

  end
end
