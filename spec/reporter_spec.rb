require 'spec_helper'
require_relative '../lib/reporter.rb'

#This test assumes data is loaded in database
describe "Reporter" do
  let(:start_time) { '2012-05-30 01:00:00' }
  let(:end_time) { '2012-05-30 04:00:00' }
  let(:reporter) { Reporter.new("reporter.db",start_time , end_time) }
  
  context "count records" do
    
    it "should have 18 matching records for given time" do
      records = reporter.overlapping_records(Time.parse(start_time), Time.parse(end_time))
      records.count.should == 18
    end
    
    it "should count all records" do
      reporter.db.get_first_value("select count(*) from transfers" ).should == 19
    end
    
    it "should have 15 matching records for start time + an hour" do
      records = reporter.overlapping_records(Time.parse(start_time), Time.parse(start_time) + 3600)
      records.count.should == 15
    end
    
    it "should have average computed per row" do
        records = reporter.overlapping_records(Time.parse(start_time), Time.parse(start_time) + 3600)
        records.first["avg"].should == 718.6132329209253        
    end
  end
  
  context "total_interval" do
    it "should report hours at boundary" do
      reporter.split_reporting_period_at_hour_boundary(start_time,end_time).should == [Time.parse(start_time), Time.parse(end_time)]  
    end
    
    it "should report hours at upper boundary for end time" do
      extra_et = Time.parse(end_time) + 3600
      et = (Time.parse(end_time) + 60).to_s
      reporter.split_reporting_period_at_hour_boundary(start_time,et).should == [Time.parse(start_time), extra_et]  
    end    
  end
  
  context "run" do
    it "should parse given rows and aggregate data" do
      records = reporter.overlapping_records(Time.parse(start_time), Time.parse(start_time) + 3600)
      time_interval,total_bytes, avg_bytes = reporter.aggregate_data(records, Time.parse(start_time), Time.parse(start_time) + 3600 )
      total_bytes.should == 360408269.82741475/Reporter::MEGABYTE
      avg_bytes.should == total_bytes/15
      time_interval.should == "01AM - 02AM"
    end
    
    it "prints the report" do
      reporter.run.should be_true
    end
  end
end