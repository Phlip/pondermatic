require "rake"
require "rake/testtask"   # Adds the Rake::TestTask class for running Ruby test files
require "listen"

CR_SOURCES = FileList["**/*.cr"]
APP_OUT    = "ponder"
SPEC_OUT   = "matic_spec"

desc "Run all"
task default: [:build, :spec, :test_libs, APP_OUT] do
#   Rake::Task["sound"].invoke("frog")
end

task :clean do
  `rm --force #{APP_OUT} #{SPEC_OUT}`
end

desc "Run Crystal specs (debug build)"
task spec: SPEC_OUT do
 sh "./#{SPEC_OUT} --verbose --no-color"
#  sh "CRYSTAL_DEBUG=1 ./#{SPEC_OUT}"
#   sh "./#{SPEC_OUT}"
end

desc "Build main app if sources changed"
file APP_OUT => CR_SOURCES do
  sh "crystal build --debug --error-trace ponder.cr -o #{APP_OUT}"
end

desc "Build spec binary if sources changed"
file SPEC_OUT => CR_SOURCES do
  `rm --force ./#{APP_OUT}`
  sh "crystal build --debug --error-trace matic_spec.cr -o #{SPEC_OUT}"
end

desc "Build everything (only if needed)"
task build: :spec

desc 'test libs'
task :test_libs do
  sh 'crystal lib/crystal-pegmatite/spec/dynamics_spec.cr --no-color'
  sh 'crystal lib/crystal-pegmatite/spec/pegmatite_spec.cr --no-color'
end

desc "Watch git files and rebuild on change"
task :watch do
  files = `git ls-files`.split("\n")

  listener = Listen.to(".", only: Regexp.union(files.map { |f| Regexp.new("^#{Regexp.escape(f)}$") })) do |_modified, _added, _removed|
    puts "🔁 Git file changed — rebuilding..."
    system("rake && rake sound[frog2]")
  end

  puts "👀 Watching git-tracked files..."
  listener.start
  sleep
end

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

# the prompt for the sound mixer demanded Gaelic language

# Rakefile — le blas Gaeilge (with a taste of Irish)

# --- Foclóir Beag (tiny glossary) ---
# ainm   = name
# fuaim  = sound
# comhad = file
# cosán  = path
# seinm  = play (music/sound)

desc "Seinn fuaim ainmhí: rake sound[kitten]" # Play an animal sound
task :sound, [:ainm] do |t, args|
  puts "le blas Gaeilge (with a taste of Irish)"
  ainm = args[:ainm] || "kitten"                 # default animal name
  cosán = File.join("scripts", "wav", "#{ainm}.wav")    # path to sound file

  unless File.exist?(cosán)
    puts "Níl an comhad fuaime ann: #{cosán}"    # Sound file not found
    exit 1
  end

  puts "Ag seinm fuaim: #{ainm} 🐾"              # Playing sound

  # Try PulseAudio first, fall back to ALSA
  system("paplay", cosán) || system("aplay", cosán)
end
