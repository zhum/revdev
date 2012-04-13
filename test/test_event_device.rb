# -*- coding:utf-8; mode:ruby; -*-

require 'test/unit'
require 'revdev'

class EventDeviceTest < Test::Unit::TestCase
  include Revdev

  @@target = "test/tmp/file"

  def initialize *args
    super

    @@target = File.expand_path @@target
    dir = File.dirname @@target
    if not File.directory? dir
      Dir.mkdir dir
    end
    FileUtils.touch @@target

  end

  def test_init
    assert_nothing_raised do
      EventDevice.new File.new @@target
      EventDevice.new @@target
    end
  end

  def test_ioctl_string_getters
    return_data = "abc\000\234\90\444"
    expected_data = "abc"
    file = File.new @@target
    $data = return_data

    def file.ioctl command, data
      if command.kind_of? Numeric
        data << $data
      else
        raise "invalid command:#{command.class}"
      end
    end

    [:device_name, :physical_location, :uniq_id, :device_prop, :global_key_state,
    :all_leds_status, :all_sounds_status, :all_switch_status].each do |m|
      evdev = EventDevice.new file
      assert_equal expected_data, evdev.method(m).call
    end
  end

  def test_read_input_event
    file = File.new @@target
    def file.read a
      "\355\247\205O\000\000\000\000\374M\005\000\000\000\000\000\001\000.\000\001\000\000\000"
    end
    evdev = EventDevice.new file
    assert_nothing_raised do
      evdev.read_input_event
    end
  end

  def test_write_key_input_event
    file = File.new @@target
    bytes =  "\355\247\205O\000\000\000\000\374M\005\000\000\000\000\000"+
      "\001\000.\000\001\000\000\000"
    ie = InputEvent.new bytes
    def file.syswrite data
    end

    evdev = EventDevice.new file
    assert_nothing_raised do
      evdev.write_input_event ie
    end
  end

end
