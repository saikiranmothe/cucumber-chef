module Cucumber
  module Chef

    class UtilityError < Error; end

    module Utility

      def is_rc?
        (Cucumber::Chef::VERSION =~ /rc/)
      end

      def locate(type, *args)
        pwd = Dir.pwd.split(File::SEPARATOR)
        (pwd.length - 1).downto(0) do |i|
          candidate = File.join(pwd[0..i], args)
          case type
          when :file
            return File.expand_path(candidate) if (File.exists?(candidate) && !File.directory?(candidate))
          when :directory
            return File.expand_path(candidate) if (File.exists?(candidate) && File.directory?(candidate))
          when :any
            return File.expand_path(candidate) if File.exists?(candidate)
          end
        end
        raise UtilityError, "Could not locate #{type} '#{File.join(args)}'."
      end

      def locate_parent(child)
        parent = (locate(:any, child).split(File::SEPARATOR) rescue nil)
        raise UtilityError, "Could not locate parent of '#{child}'." unless parent
        File.expand_path(File.join(parent[0..(parent.length - 2)]))
      end

      def spinner(stdout=STDOUT, stderr=STDERR, stdin=STDIN)
        spinning_chars = %w[| / - \\]
        count = 0
        spinner = Thread.new do
          while count do
            stdout.print spinning_chars[(count+=1) % spinning_chars.length]
            stdout.flush if stdout.respond_to?(:flush)
            sleep 0.5
            stdout.print "\b"
            stdout.flush if stdout.respond_to?(:flush)
          end
        end
        yield.tap do
          count = false
          spinner.join
        end
      end

      def generate_do_not_edit_warning(message=nil)
        warning = []
        warning << "#"
        warning << "# WARNING: Automatically generated file; DO NOT EDIT!"
        warning << [ "# Cucumber-Chef v#{Cucumber::Chef::VERSION}", message ].compact.join(" ")
        warning << "# Generated on #{Time.now.utc.to_s}"
        warning << "#"
        warning.join("\n")
      end

    end

  end
end
