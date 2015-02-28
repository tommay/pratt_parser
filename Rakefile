task :default => :test

require "rake/testtask"
Rake::TestTask.new do |t|
  t.pattern = "spec/**/*_spec.rb"
end

require "rdoc/task"
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.rdoc_files.include("lib/**/*.rb")
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
  sh "rm -fr *.gem rdoc"
end
