require 'spec_helper'

describe "POJS jasmine install" do

  before :each do
    temp_dir_before
    Dir::chdir @tmp
    @install_directory = 'pojs-example'
    Dir::mkdir @install_directory
    Dir::chdir @install_directory
  end

  after :each do
    temp_dir_after
  end

  context "when the Jasmine generators are available" do
    before :each do
      `jasmine init`
      `jasmine examples`
    end

    it "should find the Jasmine configuration files" do
      File.exists?("spec/javascripts/support/jasmine.yml").should == true
    end

    it "should find the Jasmine example files" do
      File.exists?("public/javascripts/jasmine_examples/Player.js").should == true
      File.exists?("public/javascripts/jasmine_examples/Song.js").should == true

      File.exists?("spec/javascripts/jasmine_examples/PlayerSpec.js").should == true
      File.exists?("spec/javascripts/helpers/jasmine_examples/SpecHelper.js").should == true

      File.exists?("spec/javascripts/support/jasmine.yml").should == true
    end

    it "should show jasmine rake task" do
      output = `rake -T`
      output.should include("jasmine ")
      output.should include("jasmine:ci")
    end

    it "should successfully run rake jasmine:ci" do
      output = `rake jasmine:ci`
      output.should =~ (/[1-9]\d* specs, 0 failures/)
    end

  end
end
