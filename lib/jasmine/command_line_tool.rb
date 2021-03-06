module Jasmine
  class CommandLineTool
    def cwd
      File.expand_path(File.join(File.dirname(__FILE__), '../..'))
    end

    def expand(*paths)
      File.expand_path(File.join(*paths))
    end

    def template_path(filepath)
      expand(cwd, File.join("generators", "jasmine" ,"templates", filepath))
    end

    def dest_path(filepath)
      expand(Dir.pwd, filepath)
    end

    def copy_unless_exists(relative_path, dest_path = nil)
      unless File.exist?(dest_path(relative_path))
        FileUtils.copy(template_path(relative_path), dest_path(dest_path || relative_path))
      end
    end

    def process(argv)
      if argv[0] == 'init'
        require 'fileutils'

        force = false

        if argv.size > 1 && argv[1] == "--force"
          force = true
        end

        if File.exist?("Gemfile") && open("Gemfile", 'r').read.include?('rails') && !force
          puts <<-EOF

  You're attempting to run jasmine init in a Rails project. You probably want to use the Rails generator like so:
      rails g jasmine:init

  If you're not actually in a Rails application, just run this command again with --force
      jasmine init --force
          EOF
          exit 1
        end

        FileUtils.makedirs('spec/javascripts/support')
        FileUtils.makedirs('spec/javascripts/helpers')

        unless File.exist?('spec/javascripts/helpers/.gitkeep')
          source_file = File.expand_path(File.join(File.dirname(__FILE__), '..', 'generators', 'jasmine', 'install', 'templates', 'spec', 'javascripts', 'helpers', '.gitkeep'))
          dest_file = File.expand_path(File.join(Dir.pwd, 'spec', 'javascripts', 'helpers', '.gitkeep'))
          FileUtils.copy(source_file, dest_file)
        end

        copy_unless_exists('spec/javascripts/support/jasmine.yml')
        copy_unless_exists('spec/javascripts/support/jasmine_helper.rb')
        require 'rake'
        write_mode = 'w'
        if File.exist?(dest_path('Rakefile'))
          load dest_path('Rakefile')
          write_mode = 'a'
        end

        unless Rake::Task.task_defined?('jasmine')
          File.open(dest_path('Rakefile'), write_mode) do |f|
            f.write(<<-JASMINE_RAKE)
require 'jasmine'
load 'jasmine/tasks/jasmine.rake'
JASMINE_RAKE
          end
        end
        File.open(template_path('INSTALL'), 'r').each_line do |line|
          puts line
        end
      elsif argv[0] == "examples"
        FileUtils.makedirs('public/javascripts/jasmine_examples')
        FileUtils.makedirs('spec/javascripts/jasmine_examples')
        FileUtils.makedirs('spec/javascripts/helpers/jasmine_examples')

        copy_unless_exists('jasmine-example/src/Player.js', 'public/javascripts/jasmine_examples/Player.js')
        copy_unless_exists('jasmine-example/src/Song.js', 'public/javascripts/jasmine_examples/Song.js')
        copy_unless_exists('jasmine-example/spec/PlayerSpec.js', 'spec/javascripts/jasmine_examples/PlayerSpec.js')
        copy_unless_exists('jasmine-example/spec/SpecHelper.js', 'spec/javascripts/helpers/jasmine_examples/SpecHelper.js')

        puts "Jasmine has installed some examples."
      elsif argv[0] == "license"
        puts File.new(expand(cwd, "MIT.LICENSE")).read
      else
        puts "unknown command #{argv}"
        puts "Usage: jasmine init"
        puts "               examples"
        puts "               license"
      end
    end
  end
end
