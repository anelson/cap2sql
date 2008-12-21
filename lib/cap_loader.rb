require 'rcapdissector'
require 'date'

class CapLoader
    private

    def initialize(capfile_path)
        @capfile_path = capfile_path
    end

    public

    def CapLoader.load_cap(capfile_path)
        loader = CapLoader.new(capfile_path)
        loader.load()
    end

    def load()
        puts "Loading capture file #{@capfile_path}"

        cf = Capfile.new()
        cf.filename = @capfile_path
        cf.save()
        file = CapDissector::CapFile.new(@capfile_path)

        packet_count = 0
        print "Processing packets...\r"
        file.each_packet do |packet|
            load_packet(cf, packet)

            packet_count += 1
            if (packet_count % 10 == 0) 
                print "Processed packet #{packet_count}\r"
            end
        end
        
        puts "Processed #{packet_count} packet(s)"
    end

    def load_packet(capfile, packet)
        f = Frame.new()

        # packet.timestamp format is '2008-12-18 12:03:10.166889'
        #strptime doesn't know about fractions of a second, so we'll just have to live with second resolution
        f.time = packet.timestamp != nil ? DateTime.strptime(packet.timestamp, '%Y-%m-%d %H:%M:%S') : DateTime.now
        f.number = packet.number || 0
        f.source = packet.source_address || "unknown",
        f.destination = packet.destination_address || "unknown"
        f.protocol = packet.protocol || "unknown"
        f.info = packet.info || "unknown"
        f.save

        load_packet_blobs(packet, f)
        load_packet_fields(packet, f)
        
        f.save
    end

    def load_packet_blobs(packet, db_frame)
        packet.blobs.each_pair do |key, value|
            db_frame.frame_blobs.create(
                :name => value.name,
                :value => value.value)
        end
    end

    def load_packet_fields(packet, db_frame)
        ordinal = 0
        packet.each_field do |field|
            db_frame.frame_fields.create(
                :name => field.name,
                :display_name => field.display_name,
                :display_value => field.display_value,
                :raw_value => field.value,
                :ordinal => ordinal)

            ordinal += 1
        end

    end

end

