# typed: strict

require 'sorbet-runtime'

class RangeSet
  # stores a set of integers as a list of ranges

  extend T::Sig

  class Range < T::Struct
    prop :start, Integer
    prop :end, Integer
  end

  sig {returns(T::Array[Range])}
  attr_accessor :ranges

  sig {void}
  def initialize()
    @ranges = T.let([], T::Array[Range])
  end

  sig {params(num: Integer).returns(T::Boolean)}
  def add(num)
    inserted = false
    if right = @ranges.bsearch_index { |r| r.start >= num }
      right_start = T.must(@ranges[right]).start
      return false if right_start == num # already in set
      if right_start == num + 1 # merge right range
        T.must(@ranges[right]).start = num
        inserted = true
      end
    end
    left = right ? right - 1 : @ranges.length - 1
    if left >= 0
      left_end = T.must(@ranges[left]).end
      return false if left_end >= num # already in set
      if left_end == num - 1 # merge left range
        if inserted # already merged to right range
          T.must(@ranges[right]).start = T.must(@ranges[left]).start
          @ranges.delete_at(left)
        else
          T.must(@ranges[left]).end = num
          inserted = true
        end
      end
    end
    if !inserted
      @ranges.insert(left + 1, Range.new(start: num, end: num))
    end
    true
  end

  sig {params(num: Integer).returns(T::Boolean)}
  def delete(num)
    if container = @ranges.bsearch_index { |r| r.end >= num }
      if T.must(@ranges[container]).start <= num
        new_ranges = []
        if num > T.must(@ranges[container]).start
          new_ranges.push Range.new(start: T.must(@ranges[container]).start, end: num - 1)
        end
        if num < T.must(@ranges[container]).end
          new_ranges.push Range.new(start: num + 1, end: T.must(@ranges[container]).end)
        end
        @ranges.delete_at container
        while new_range = new_ranges.pop
          @ranges.insert(container, new_range)
        end
        return true
      end
    end
    false
  end

  sig {params(num: Integer).returns(T::Boolean)}
  def include?(num)
    if range = @ranges.bsearch { |r| r.end >= num }
      range.start <= num
    else
      false
    end
  end

  sig {params(path: String).void}
  def save(path)
    ranges = @ranges.map{ |r| [r.start, r.end] }
    File.open(path, 'wb') { |f| f.write(T.cast(Marshal.dump(ranges), String)) }
  end

  sig {params(path: String).void}
  def load(path)
    if File.file?(path)
      ranges = T.cast(Marshal.load(File.binread(path)), T::Array[[Integer, Integer]])
      @ranges = ranges.map{ |s, e| Range.new(start: s, end: e) }
    end
  end

  sig {void}
  def _check_invariants()
    # all ranges are valid
    @ranges.each { |range| raise "invalid range" if range.start > range.end }

    # ranges are sorted
    (1...@ranges.length).each do |i|
      raise "ranges not sorted" if T.must(@ranges[i]).start <= T.must(@ranges[i-1]).end
    end
  end
end
