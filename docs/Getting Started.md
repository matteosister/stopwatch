# Getting Started

**Some basic examples to start easy**

Stopwatch is a library to measure elapsed time. It's main use is code profiling and logging.

### Basic Usage

```
watch = Stopwatch.Timer.start
long_computation()
watch = Stopwatch.Timer.stop(watch) # remember, immutability!
IO.puts Stopwatch.Watch.total_time(watch) # 16839.722, number of milliseconds elapsed
```

if you don't want to write the full modules name just

```
use Stopwatch
```

and than you can just use **Timer** and **Watch**

You call the *Timer* module to start, stop, lap the timers. When you have done you call the *Timer.stop/1* method which returns a *Watch*. Then you use the Watch module to access the final results.
