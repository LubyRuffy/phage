require 'forwardable'

require 'playful/ssdp'

require 'net/http'
require 'pp'

# fetch /description.xml and use it to learn about the device
module Phage
  class Scan
    class Upnp
      include Enumerable

      extend Forwardable
      def_delegators :collection, :each, :<<, :size

      attr_accessor :collection

      def initialize
        start = Time.now

        @collection = []

        puts "init"
        all_devices = []
        res = Playful::SSDP.search :all
        all_devices += res if res
        res = Playful::SSDP.search :all, do_broadcast_search: true
        all_devices += res if res
        res = Playful::SSDP.search("urn:Belkin:device:controllee:1")
        all_devices += res if res

        @collection += all_devices

        puts "found #{all_devices.length} UPNP devices"
        all_devices.each do |dev|
         ::Upnp.where(usn: dev[:usn]).first_or_create(st: dev[:st],
                                                      location: dev[:location],
                                                      usn: dev[:usn],
                                                      server: dev[:server],
                                                      cache_control: dev[:cache_control],
                                                      device: Phage::Scan::Upnp::get_device(dev),
                                                      ext: dev)
        end

        complete = Time.now

        ::Scan.create scan_type: 'upnp', start: start, end: complete

        all_devices.length
      end

      def self.poke_all
        Device.all.each do |dev|
          discovery_msg = <<END_OF_DISCOVER_MSG
M-SEARCH * HTTP/1.1
HOST: #{dev.ipv4.first}:1900
MAN: ssdp:discover
MX: 10
ST: ssdp:all
END_OF_DISCOVER_MSG
        end

        Socket.udp_server_loop(@port) do |data, src|
          
        end
      end

      def self.probe_device(upnp)
        begin
          uri = URI(upnp[:location])
        rescue
          puts "URI fail #{upnp[:location]}"
          return
        end

        begin
          results = Net::HTTP.get(uri)
        rescue
          puts "HTTP fail #{upnp[:location]}"
          return
        end

        if results
          begin
            return Hash.from_xml(results)
          rescue
            puts "fail to parse #{upnp[:location]}"
            pp results
            return
          end
        end
      end

      def self.get_device(dev)
        m = dev[:location].match /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/
        return unless m

        Device.where("'#{m[1]}' = ANY(ipv4)").first
      end
    end
  end
end
