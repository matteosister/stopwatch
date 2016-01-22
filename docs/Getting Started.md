# Getting Started

**Some basic examples to start easy**

Stopwatch is a library to measure elapsed time. It's main use is code profiling and logging.

### Basic Usage

```
use Stopwatch
watch = Watch.new
# long_computation()
watch = Watch.stop(watch) # remember, immutability!
IO.puts Watch.get_total_time(watch) # 16839.722, number of milliseconds elapsed
```

### Laps

You can use this feature to store many laps on a single timer

Then you are able to get back the total time, the laps time, and a single lap time

```
use Stopwatch
watch = Watch.new
# long_computation()
watch = Watch.lap(watch, "long computation")

# another_piece_of_code()
watch = Watch.last_lap(watch, "another_piece_of_code")

IO.puts Watch.get_total_time(watch, :secs)
# 16.839722, number of seconds elapsed

IO.inspect Watch.get_laps(watch, :secs)
# [{"long computation", 6.544463}, {"another_piece_of_code", 10,295259}]

IO.inspect Watch.get_lap_time(watch, "long computation", :secs)
# 6.544463
```
