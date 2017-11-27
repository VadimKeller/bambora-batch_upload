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

    def self.create_file txn_type, &block
      raise "provide a block" unless block_given?
      @file_path = CreateBatchFile.new(create_array(txn_type,&block)).call
      if @file_path.nil?
        raise "No file generated!!!" 
      else
        @file_path
      end
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

    def self.create_array txn_type, &block
      reader = MakeArray.new txn_type
      yield(reader)
      reader.array
    end

    class MakeArray
      attr_accessor :array, :txn_type
      def initialize(txn_type)
        @txn_type = txn_type
        @array    = []
      end
      def push_into_file(params)
        validate_args params
        array << OpenStruct.new(txn_type:               @txn_type,
                                payment_type:           params[:payment_type].to_s,
                                institution_number:     params[:institution_number].to_s,
                                transit_number:         params[:transit_number], 
                                transit_routing_number: params[:transit_routing_number].to_s,
                                account_number:         params[:account_number].to_s,
                                account_code:           params[:account_code].to_s,
                                amount:                 params[:amount],
                                ref:                    (params[:reference] || 0 ).to_s,
                                recipient:              params[:recipient].to_s,
                                customer_code:          params[:customer_code].to_s,
                                descriptor:             params[:dynamic_descriptor].to_s,
                                standard_entry_code:    params[:standard_entry_code].to_s,
                                entry_detail_addenda:   params[:entry_detail_addenda_record].to_s
                               )
      end
      private
      def validate_args params
        unless @txn_type == "E" || @txn_type == "A"
          raise ArgumentError, "Must specify transaction type: E (EFT) or A (ACH)" 
        end
        unless params[:payment_type] == "D" || params[:payment_type] == "C"
          raise ArgumentError, "Must provide payment type: C (credit) or D (debit)" 
        end
        if params[:amount].nil?
          raise ArgumentError, "Must provide amount"       
        end
        #banking info
        if @txn_type == "E"
          if params[:customer_code].nil? && (params[:transit_number].nil? || 
                                             params[:institution_number].nil? ||
                                             params[:account_number].nil?)
            raise ArgumentError, "Must either provide customer code or transit, institution, and account #s"
          end
        else
          if params[:customer_code].nil? && (params[:transit_routing_number].nil? || 
                                             params[:account_code].nil? ||
                                             params[:account_number].nil?)
            raise ArgumentError, "Must either provide customer code or transit routing, account #s, and accounting code"
          end
        end
      end
    end
    
    private

    def self.config_complete 
      merchant_id && batch_upload_api_key
    end

  end
end
