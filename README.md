# Stopwatch

[![Build Status](https://travis-ci.org/matteosister/stopwatch.svg?branch=master)](https://travis-ci.org/matteosister/stopwatch)

stopwatch provides an easy api to measure elapsed time and
profile code.

## Installation

The package can be installed as:

  1. Add stopwatch to your list of dependencies in `mix.exs`:

        def deps do
          [{:stopwatch, "~> 0.0.1"}]
        end

  2. Ensure stopwatch is started before your application:

        def application do
          [applications: [:stopwatch]]
        end
