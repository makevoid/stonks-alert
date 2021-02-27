desc "Run UI"
task :ui do
  sh "bundle exec rackup"
end

desc "Run background process"
task :run do
  sh "bundle exec ruby lib/main.rb"
end

task default: :run
