How to run

unzip the directory
Ensure that you have sqllite installed
Ensure you have ruby 1.9.3
Install the bundler gem
run bundle install to install gems (I used pry and rspec)

To prepare data
  run sqlite3 reporter.db
  I have the file with the data preloaded in transfers table.  

If you want to run in cleanly in a default instance - do the following
  run following commands in sqlite3 console
  create table transfers ( xfer_start datetime, xfer_end datetime, bytes_transferred integer);
  .mode csv
  .separator ","
  .import ./bandwidth_report_sample_data.csv transfers
  #clean up the table to remove headers
  delete from transfers where xfer_start='xfer_start';

Test
  Ensure that select count(*) from transfers => 19

Run
  run ruby lib/reporter.rb
  Better yet run - bundle exec rake spec

Tests
rake -T will show all tasks
To run default tests,  bundle exec rake spec. There is a test that will print the final output

Approach

The approach to calculating overlaps is simple. The idea is to figure out if the transfer_start_time is less than the interval end time and transfer_end_time is greater than interval start time

I have written a simple program that works. I am consulting for a client at the moment and did not have lot of time to polish it. In real world, I would move db initialization into its own class, queries in a repository class, string and data manipulations into a helper library that I will mixin and a the main reporter class. In addition, I would have a main class that parses user options


Edge Cases
I have not handled edge cases. I am assuming that ranges is given correctly in input such that start_time < end_time


Other approaches
1. segment time and query databases for overlaps - sum and avg

select  sum(bytes_transferred*1.0/(strftime('%s',xfer_end) - strftime('%s',xfer_start)))  from transfers where xfer_start <= "2012-05-30 02:00:00" and xfer_end >= "2012-05-30 01:00:00";

select  avg(bytes_transferred*1.0/(strftime('%s',xfer_end) - strftime('%s',xfer_start)))/(1024*1024)  from transfers where xfer_start <= "2012-05-30 04:00:00" and xfer_end >= "2012-05-30 03:00:00";
21.4160583016406