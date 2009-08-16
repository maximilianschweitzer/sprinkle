require File.dirname(__FILE__) + '/../../spec_helper'

describe Sprinkle::Installers::UncommentLine do

  before do
    @package = mock(Sprinkle::Package, :name => 'package')
    @options = {:sudo => true}
  end

  def create_uncomment_line(regex, path, options={}, &block)
    Sprinkle::Installers::UncommentLine.new(@package, regex, path, options, &block)
  end

  describe 'when created' do

    it 'should accept regex line description to uncomment and path' do
      @installer = create_uncomment_text 'line_to_uncomment', '/etc/example/foo.conf'
      @installer.regex.should == 'line_to_uncomment'
      @installer.path.should == '/etc/example/foo.conf'
    end

  end

  describe 'during installation' do

    before do
      @installer = create_uncomment_text 'line to include', '/etc/brand/new.conf' do
        pre :install, 'op1'
        post :install, 'op2'
      end
      @install_commands = @installer.send :install_commands
    end

    it 'should invoke the replace text installer for all specified packages' do
      @install_commands.should == %q[sed -i 's/#\(.*line to include.*\)/\1/' /etc/brand/new.conf]
    end
    
    it 'should automatically insert pre/post commands for the specified package' do
      @installer.send(:install_sequence).should == [ 'op1', "sed -i 's/#\\(.*line to include.*\\)/\\1/' /etc/brand/new.conf", 'op2' ]
    end

  end

end
