# typed: ignore

require 'minitest/autorun'
require 'tempfile'

require_relative '../lib/range_set'

class RangeSetTest < Minitest::Test
  def test_false
    assert false
  end

  def test_add
    rs = RangeSet.new
    rs.add 1
    assert rs.include?(1)
  end

  def test_delete
    rs = RangeSet.new
    rs.add 1
    rs.delete 1
    refute rs.include?(1)
  end

  def test_add_twice
    rs = RangeSet.new
    assert rs.add(1)
    refute rs.add(1)
    assert rs.include?(1)
    assert rs.delete(1)
    refute rs.delete(1)
  end

  def test_merge
    rs = RangeSet.new
    rs.add 1
    rs.add 3
    assert_equal rs.ranges.length, 2
    rs.add 2
    assert_equal rs.ranges.length, 1
    assert rs.include?(2)
  end

  def test_split
    rs = RangeSet.new
    rs.add 1
    rs.add 2
    rs.add 3
    assert_equal rs.ranges.length, 1
    rs.delete 2
    assert_equal rs.ranges.length, 2
  end

  def test_delete_first
    rs = RangeSet.new
    rs.add 1
    rs.add 2
    rs.add 3
    rs.delete 1
    assert rs.include?(2)
    assert rs.include?(3)
  end

  def test_delete_last
    rs = RangeSet.new
    rs.add 1
    rs.add 2
    rs.add 3
    rs.delete 3
    assert rs.include?(1)
    assert rs.include?(2)
  end

  def test_merge_ranges
    rs = RangeSet.new
    rs.add 4
    rs.add 5
    assert_equal rs.ranges.length, 1
    rs.add 1
    rs.add 2
    assert_equal rs.ranges.length, 2
    rs.add 3
    assert_equal rs.ranges.length, 1
  end

  def test_save_and_load
    file = Tempfile.new('range_set_test')
    rs = RangeSet.new
    rs.add 1
    rs.save file.path
    rs.delete 1
    rs.add 2
    rs.load file.path
    assert rs.include?(1)
    refute rs.include?(2)
    file.unlink
  end
end
