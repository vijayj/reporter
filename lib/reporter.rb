require 'sqlite3'
require 'time'

class Reporter
  attr_reader :db
  MEGABYTE = 1024.0 * 1024.0
  
  def initialize(db_name, start_time, end_time)
    @db_name = db_name
    @start_time = start_time
    @end_time = end_time
    @db = SQLite3::Database.new @db_name
    @db.type_translation = true
    @db.results_as_hash = true
  end
  
  def run      
    #this can be extended to days too
    hour_start,hour_end = split_reporting_period_at_hour_boundary(@start_time, @end_time)
    hour = hour_start
    output = []
    while(hour < hour_end)
      end_time = hour + 3600
      records = overlapping_records(hour, end_time)
      output << aggregate_data(records, hour, end_time)
      hour = end_time
    end
    
    print_formatted output
  end
  
  def print_formatted lines
    printf "%-20s %s %20s\n","Time interval","Total (in MB)", "Avg (in MB) "
    lines.each do |row|
      printf "%-20s %s %20s\n", row[0], row[1], row[2]
    end
  end
  
  def aggregate_data(records, start_time, end_time)
    sum = 0
    count = 0
    records.each do |r|
      sum += r['avg']
      count += 1
    end
    
    total = sum/MEGABYTE    
    avg = total/count
    time_interval = "#{format_hour(start_time)} - #{format_hour(end_time)}"
    [time_interval,total,avg]
  end  
  
  def split_reporting_period_at_hour_boundary(start_time, end_time)
    hs = Time.parse(start_time)
    hour_start = Time.local(hs.year,hs.month,hs.day, hs.hour)
    he = Time.parse(end_time)
    if(he.min > 0 || he.sec > 0)
      hour_end = Time.local(he.year, he.month, he.day, he.hour + 1)
    else
      hour_end = Time.local(he.year, he.month, he.day, he.hour )
    end
    [hour_start, hour_end]
  end
  
  def overlapping_records(st_time, et_time)
    stmt = db.prepare( "select xfer_start,xfer_end,bytes_transferred, bytes_transferred*1.0/(strftime('%s',xfer_end) - strftime('%s',xfer_start)) as avg from transfers where xfer_start <= :end_time and xfer_end >= :start_time")
    stmt.bind_params("end_time" => format_time_for_db(et_time), "start_time" => format_time_for_db(st_time))
    stmt.execute    
  end
  
  def format_time_for_db(time)
    time.strftime "%Y-%m-%d %H:%M:%S"
  end
  
  def format_hour(time)
    time.strftime "%H%p"
  end
end


Reporter.new("reporter.db", '2012-05-30 01:00:00','2012-05-30 04:00:00').run


