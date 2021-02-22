desc "Run"
task :run do
  sh "bundle exec rackup"
end

desc "Run background process"
task :main do
  sh "bundle exec ruby lib/main.rb"
end

task default: :run
