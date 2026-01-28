require "rake"
require "rake/testtask"   # Adds the Rake::TestTask class for running Ruby test files

desc "Run Crystal specs"
task :spec do
  sh "crystal spec matic_spec.cr"
end

desc "Build"
task :build do
  sh 'crystal build --debug ponder.cr'
#  sh 'lldb ./ponder'
end

desc "Run all"
task default: [:build, :spec] do # how to put a rake sound[frog] here?
  Rake::Task["sound"].invoke("frog")
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

#
# ---- Combined ----
#
# desc "Run all tests (Ruby + Crystal)"
# task test: [:ruby, :crystal]
#
# task default: :test


# Rakefile — le blas Gaeilge (with a taste of Irish)

# --- Foclóir Beag (tiny glossary) ---
# ainm   = name
# fuaim  = sound
# comhad = file
# cosán  = path
# seinm  = play (music/sound)

desc "Seinn fuaim ainmhí: rake sound[kitten]" # Play an animal sound
task :sound, [:ainm] do |t, args|
  ainm = args[:ainm] || "kitten"                 # default animal name
    cosán = File.join("scripts", "#{ainm}.wav")    # path to sound file

  unless File.exist?(cosán)
    puts "Níl an comhad fuaime ann: #{cosán}"    # Sound file not found
    exit 1
  end

  puts "Ag seinm fuaim: #{ainm} 🐾"              # Playing sound

  # Try PulseAudio first, fall back to ALSA
  system("paplay", cosán) || system("aplay", cosán)
end
