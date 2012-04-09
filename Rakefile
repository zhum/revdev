#!/usr/bin/env rake
# -*- coding:utf-8; mode:ruby; -*-

require "bundler/gem_tasks"
require 'rake/testtask'
require 'rake/clean'

NAME = 'revdev'
MAKEFILES = Dir.glob "ext/**/Makefile"

directory "lib/#{NAME}"

file "lib/#{NAME}/#{NAME}.so" =>
  (Dir.glob("ext/#{NAME}/*.{rb,c}") << "lib/#{NAME}")do

  Dir.chdir "ext/#{NAME}" do
    ruby "extconf.rb"
    sh "make"
  end

  cp "ext/#{NAME}/#{NAME}.so", "lib/#{NAME}"

end

desc "Run tests"
task :test => "lib/#{NAME}/#{NAME}.so"

desc "do `make clean` with all Makefiles"
task :make_clean do
  MAKEFILES.each do |file|
    dir = File.dirname file
    puts "cd #{dir}"
    Dir.chdir dir do
      sh "make clean"
    end
  end
end

CLOBBER.include "lib/**/*.so"

CLEAN.include MAKEFILES
task :clean => :make_clean

class Rake::SudoTestTask < Rake::TestTask
  def define
    desc "Run tests" + (@name==:test ? "" : " for #{@name}") + " as root"
    task @name do
      sh %!sudo env PATH="#{ENV['PATH']}" ruby #{ruby_opts_string} #{run_code} #{file_list_string} #{option_list}!
    end
    self
  end
end

Rake::SudoTestTask.new :test do |t|
  t.verbose = true
end

task :default => :test
