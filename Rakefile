require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.pattern = "spec/**/*_spec.rb"
end

task :gem do
  sh "gem build pratt_parser.gemspec"
end

task :install => :gem do
  sh "gem install pratt_parser"
end

task :push => [:clean, :gem] do
  sh "gem push pratt_parser-*.gem"
end

task :clean do
  sh "rm -f *.gem"
end
