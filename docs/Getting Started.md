# Getting Started

**Some basic examples to start easy**

Stopwatch is a library to measure elapsed time. It's main use is code profiling and logging.

### Basic Usage

```
watch = Stopwatch.Watch.new
long_computation()
watch = Stopwatch.Watch.stop(watch) # remember, immutability!
IO.puts Stopwatch.Watch.Watch.total_time(watch) # 16839.722, number of milliseconds elapsed
```

if you don't want to write the full modules name just

```
use Stopwatch
```

and than you can just use **Watch** as module name
