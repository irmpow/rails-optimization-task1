require "ruby-prof"
require_relative "task-1.rb"

RubyProf.measure_mode = RubyProf::WALL_TIME

result = RubyProf.profile do
  work "data16.txt"
end

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open("ruby_prof_reports/callstack.html", "w+"))