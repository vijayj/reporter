How to run

unzip the directory
Ensure that you have sqllite installed
Ensure you have ruby 1.9.3
Install the bundler gem
run bundle install to install gems (I used pry and rspec)

To install database
run sqlite3 reporter.db
run following commands in sqlite3 console
create table transfers ( xfer_start datetime, xfer_end datetime, bytes_transferred integer);
.mode csv
.import ./bandwidth_report_sample_data.csv transfers
delete from transfers where xfer_start='xfer_start';
Enusre that select count(*) from transfers => 19

run ruby lib/match.rb -f spec/fixtures/words_for_problem.txt 


Tests
rake -T will show all tasks
To run default tests, run rake spec . There are 2 tests in the spec class that read the entire input

Benchmarks
run rake spec_with_benchmarks
There are 2 tests. The first one assumes that word list is created by another class and passed to the matcher.
The second one reads the file in the class. I have found that reading the file in with ruby is slow


Approach

The approach to calculating overlaps is simple. The idea is...

I have written a simple program given that I am working for a client and don't really have lots of time during weekdays to work on the issue. In real world, I would move db initialization into its own class, queries in a repository class, string and data manipulations into a helper library that I will mixin and a the main reporter class. In addition, I would have a main class that parses user options

Other approaches

1. segment time and query databases for overlaps

select  sum(bytes_transferred*1.0/(strftime('%s',xfer_end) - strftime('%s',xfer_start)))  from transfers where xfer_start <= "2012-05-30 02:00:00" and xfer_end >= "2012-05-30 01:00:00";
select  avg(bytes_transferred*1.0/(strftime('%s',xfer_end) - strftime('%s',xfer_start)))  from transfers where xfer_start <= "2012-05-30 02:00:00" and xfer_end >= "2012-05-30 01:00:00";
24027217.9884943

select  avg(bytes_transferred*1.0/(strftime('%s',xfer_end) - strftime('%s',xfer_start)))/(1024*1024)  from transfers where xfer_start <= "2012-05-30 04:00:00" and xfer_end >= "2012-05-30 03:00:00";
21.4160583016406