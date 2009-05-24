#!/usr/bin/ruby

require 'fileutils'

# le a entrada linha a linha
i=0.0
STDIN.each do |l|
  puts "#{(i/50)-4*(3.14159245358978)} #{l}"
  i+=1
end

