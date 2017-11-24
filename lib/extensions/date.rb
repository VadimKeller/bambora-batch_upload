require 'holidays'
require 'holidays/core_extensions/date'
class Date 
  include Holidays::CoreExtensions::Date

  def self.next_business_day buffer=0
    day = Date.today+buffer
    begin
      day += 1
    end while(day.is_bc_time_off?)
    day
  end

  def self.monday 
    1
  end

  def is_bc_time_off?
    self.holiday?(:ca_bc) || Date.weekend.include?(self.wday) || self.sub_day?
  end

  def self.weekend 
    [0,6]
  end

  def sub_day? 
    self.wday == self.class.monday && ( (self-1.day).holiday?(:ca_bc) || (self-2.day).holiday?(:ca_bc) )
  end

end
