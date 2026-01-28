require "rake"
require "rake/testtask"   # Adds the Rake::TestTask class for running Ruby test files

desc "Run Crystal specs"
task :spec do
  sh "crystal spec matic_spec.cr"
end

desc "Run all"
task default: :spec

#
# ---- Ruby tests (if you ever add any) ----
#
Rake::TestTask.new(:ruby) do |t|
  t.libs << "lib"
  t.pattern = "test/**/*_test.rb"
  t.verbose = true
end

#
# ---- Crystal specs ----
#
desc "Run Crystal specs"
task :crystal do
  sh "crystal spec matic_spec.cr"
end

#
# ---- Combined ----
#
# desc "Run all tests (Ruby + Crystal)"
# task test: [:ruby, :crystal]
#
# task default: :test
