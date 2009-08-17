module Sprinkle
  module Installers
    # = Replace text installer
    #
    # This installer uncomments a one or multiple lines in a file.
    # 
    # == Example Usage
    #
    # Uncomment multiverse repository in Ubuntu Jaunty (make it active).
    # jaunty.* is necessary to make sure that real comment sections are
    # ignored and only package source statements are uncommented
    #
    #   package :magic_beans do
    #     uncomment_line 'jaunty.*multiverse', '/etc/apt/sources.list'
    #   end
    #
    # You can also uncomment multiple lines with different regex in one file
    #
    #   package :magic_beans do
    #     uncomment_line [ 'jaunty.*multiverse', 'jaunty.*partner' ], '/etc/apt/sources.list'
    #   end
    #
    # If you user has access to 'sudo' and theres a file that requires
    # priveledges, you can pass :sudo => true 
    #
    #   package :magic_beans do
    #     uncomment_line 'multiverse', '/etc/apt/sources.list', :sudo => true
    #   end
    #
    # A special verify step exists for this very installer
    # its known as file_contains, it will test that a file indeed
    # contains a substring that you send it.
    #
    class UncommentLine < Installer
      attr_accessor :regex, :path #:nodoc:

      def initialize(parent, regex, path, options={}, &block) #:nodoc:
        super parent, options, &block
        @regex = regex
        @path = path
      end

      protected

        def install_commands #:nodoc:
          command = ""
          if @regex.kind_of? Array
             @regex.each {|current_regex| command += uncomment(current_regex) + "; "}
          else
             command = uncomment(@regex)
          end
          return command
        end
        
        def uncomment(regex) #:nodoc:
            logger.info "--> Uncomment lines which contains '#{regex}' in file #{@path}"
            "#{'sudo' if option?(:sudo)} sed -i 's/#\\(.*#{regex.gsub("'", "'\\\\''").gsub("/", "\\\\/").gsub("\n", '\n')}.*\\)/\\1/' #{@path}"
        end
    end
  end
end
