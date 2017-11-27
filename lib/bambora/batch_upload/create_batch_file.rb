require 'securerandom'
require 'date'

module Bambora::BatchUpload
  class CreateBatchFile
    
    attr_accessor :txn_array

    def initialize(txn_array)
      @txn_array = txn_array
    end
  
    def call 
      create_file 
    end
  
    private
  
    def create_file
      string    = file_content
      begin
        path = "#{Bambora::BatchUpload.get_batch_file_path}/#{batch_file_name}"
        file = File.open(path, "w")
        file.write(string) 
      rescue IOError => e
        puts "Write Fail"
      ensure
        file.close unless file.nil?
      end
      path
    end
  
    def batch_file_name
      file_name = "#{SecureRandom.hex(4)}_#{DateTime.now.strftime("%b_%d_%Y_%H:%M:%S:%L")}.txt"
    end
  
    def file_content
      string  = "" 
      txn_array.each do |txn|
        string << "#{txn.txn_type},"     #E for EFT, A for ACH
        string << "#{txn.payment_type}," #C for Credit, D for Debit
        if txn.txn_type == "E"
          string << "#{txn.institution_number},"
          string << "#{txn.transit_number},"
          string << "#{txn.account_number},"
        else
          string << "#{txn.transit_routing_number},"
          string << "#{txn.account_number},"
          string << "#{txn.account_code},"
        end
        string << "#{txn.amount},"
        string << "#{txn.ref},"
        string << "#{txn.recipient},"
        string << "#{txn.customer_code},"
        string << "#{txn.descriptor}"
        if txn.txn_type == "A"
          string << ",#{txn.standard_entry_code}," #add comma at beginning to separate from above
          string << "#{txn.entry_detail_addenda}"
        end
        string << "\r\n"
      end
      string
    end
  
  end
end
