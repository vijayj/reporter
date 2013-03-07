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
    begin
      he = hour_start + 3600
      records = overlapping_records(hour_start, he)
      output << aggregate_data(records, hour_start, he)
      hour_start = he
    end while (hour_start) < hour_end
    
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
    time_interval = "#{start_time.strftime('%H%p')} - #{end_time.strftime('%H%p')}"
    [time_interval,total,avg]
  end  
    
  def report_per_hour(start_hour)
    start_hour
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
    st_time = st_time.strftime "%Y-%m-%d %H:%M:%S"
    et_time = et_time.strftime "%Y-%m-%d %H:%M:%S"
    # p "overlapping records #{st_time}..#{et_time}"
    # stmt = db.prepare( "select * from transfers where xfer_start <= '#{et_time}' and xfer_end >= '#{st_time}'" )
    stmt = db.prepare( "select xfer_start,xfer_end,bytes_transferred, bytes_transferred*1.0/(strftime('%s',xfer_end) - strftime('%s',xfer_start)) as avg from transfers where xfer_start <= :end_time and xfer_end >= :start_time")
    # select xfer_start,xfer_end,bytes_transferred, bytes_transferred*1.0/(strftime('%s',xfer_end) - strftime('%s',xfer_start)) from transfers where xfer_start <= "2012-05-30 02:00:00" and xfer_end >= "2012-05-30 01:00:00";
    stmt.bind_params("end_time" => et_time, "start_time" => st_time)
    stmt.execute    
  end

  # def run
  #   w = WordMatcher.load_from_file(@word_file)
  #   w.find
  #   p "longest word is - #{w.longest_match}"
  #   p "Total count of matching long words from words - #{w.all_matched_words_count}"
  # rescue Errno::ENOENT => e
  #   p "Seems like we have a missing file. please pass in a valid file"
  # end
end

# 
# options = {}
# optparse = OptionParser.new do |opts|
#   opts.banner = "Usage: ruby match.rb [options]"
# 
#   opts.on("-f", "--filename FILENAME", "file with words") do |f|
#     options[:filename] = f
#   end
# end
# 
# begin
#   optparse.parse!
#   if options[:filename].nil?
#     puts optparse
#     puts exit
#   end
# rescue OptionParser::InvalidOption, OptionParser::MissingArgument => e
#   puts e.to_s
#   puts optparse
#   exit
# end
# 
# puts "Starting matcher with arguments: #{options.inspect}"
Reporter.new("reporter.db", '2012-05-30 01:00:00','2012-05-30 04:00:00').run


