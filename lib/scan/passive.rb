#require 'arp'

require 'forwardable'

class Scan
  class Passive
    include Enumerable

    extend Forwardable
    def_delegators :collection, :each, :<<, :size

    attr_accessor :collection
    
    def initialize
      @collection = []

      system "ping -b -c 1 -W 1 255.255.255.255 >/dev/null 2>&1 &"
      system "ping -b -c 1 -W 1 10.0.1.255 >/dev/null 2>&1 &"
      Device.find_each do |dev|
        system "ping -c 1 -W 1 #{dev[:ipv4]} >/dev/null 2>&1 &"
      end
    
      lines = `/usr/sbin/arp -a`.split "\n"
      lines.each do |line|
        match = line.match /\((\d+\.\d+\.\d+\.\d+)\) at (\h{1,2}:\h{1,2}:\h{1,2}:\h{1,2}:\h{1,2}:\h{1,2}) \[ether\] on (\S+)/
        next unless match

        @collection.push({ ipv4: match[1], mac_address: match[2], interface: match[3] })
      end
    end
  end
end

