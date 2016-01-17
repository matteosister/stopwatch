defmodule Stopwatch.WatchRepoTest do
  use ExUnit.Case
  use Stopwatch

  setup do
    WatchRepo.clear_all
  end

  test "count empty is 0" do
    assert 0 === WatchRepo.count
  end

  test "count after insert is 1" do
    WatchRepo.store(Watch.new, :test)
    assert 1 === WatchRepo.count
  end

  test "count after insert and pop is 0" do
    WatchRepo.store(Watch.new, :test2)
    WatchRepo.pop(:test2)
    assert 0 === WatchRepo.count
  end
end
