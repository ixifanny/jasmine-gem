require 'spec_helper'

describe 'Jasmine command line tool' do
  before :each do
    temp_dir_before
    Dir::chdir @tmp
  end

  after :each do
    temp_dir_after
  end

  describe '.init' do
    describe 'without a Gemfile' do
      it 'should create files on init' do
        output = capture_stdout { Jasmine::CommandLineTool.new.process ['init'] }
        output.should =~ /Jasmine has been installed\./

        File.exists?(File.join(@tmp, 'spec/javascripts/helpers/.gitkeep')).should == true
        File.exists?(File.join(@tmp, 'spec/javascripts/support/jasmine.yml')).should == true
        File.exists?(File.join(@tmp, 'Rakefile')).should == true
        ci_output = `rake --trace jasmine:ci`
        ci_output.should =~ (/0 specs, 0 failures/)
      end
    end

    describe 'with a Gemfile containing Rails' do
      before :each do
        open(File.join(@tmp, "Gemfile"), 'w') do |f|
          f.puts "rails"
        end
      end

      it 'should warn the user' do
        output = capture_stdout {
          expect {
            Jasmine::CommandLineTool.new.process ['init']
          }.to raise_error SystemExit
        }
        output.should =~ /attempting to run jasmine init in a Rails project/

        Dir.entries(@tmp).sort.should == [".", "..", "Gemfile"]
      end

      it 'should allow the user to override the warning' do
        output = capture_stdout {
          expect {
            Jasmine::CommandLineTool.new.process ['init', '--force']
          }.not_to raise_error
        }
        output.should =~ /Jasmine has been installed\./

        File.exists?(File.join(@tmp, 'spec/javascripts/helpers/.gitkeep')).should == true
        File.exists?(File.join(@tmp, 'spec/javascripts/support/jasmine.yml')).should == true
      end
    end

    describe 'with a Gemfile not containing Rails' do
      before :each do
        open(File.join(@tmp, "Gemfile"), 'w') do |f|
          f.puts "sqlite3"
        end
      end

      it 'should perform normally' do
        output = capture_stdout {
          expect {
            Jasmine::CommandLineTool.new.process ['init']
          }.not_to raise_error
        }
        output.should =~ /Jasmine has been installed\./

        File.exists?(File.join(@tmp, 'spec/javascripts/helpers/.gitkeep')).should == true
        File.exists?(File.join(@tmp, 'spec/javascripts/support/jasmine.yml')).should == true
      end
    end
  end

  describe '.examples' do
    it 'should install the examples' do
      output = capture_stdout { Jasmine::CommandLineTool.new.process ['examples'] }
      output.should =~ /Jasmine has installed some examples\./
      File.exists?(File.join(@tmp, 'public/javascripts/jasmine_examples/Player.js')).should == true
      File.exists?(File.join(@tmp, 'public/javascripts/jasmine_examples/Song.js')).should == true
      File.exists?(File.join(@tmp, 'spec/javascripts/jasmine_examples/PlayerSpec.js')).should == true
      File.exists?(File.join(@tmp, 'spec/javascripts/helpers/jasmine_examples/SpecHelper.js')).should == true

      capture_stdout { Jasmine::CommandLineTool.new.process ['init'] }
      ci_output = `rake --trace jasmine:ci`
      ci_output.should =~ (/[1-9]\d* specs, 0 failures/)
    end
  end

  it 'should include license info' do
    output = capture_stdout { Jasmine::CommandLineTool.new.process ['license'] }
    output.should =~ /Copyright/
  end
end
