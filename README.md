# Pondermatic

an AI toolchain using Crystal Language

the toolchain's toolchain is a Ruby Rakefile. Converting it to Crystal is left as an exercise 
for the bored. 

don't read farther without basic Crystal Language and Rakefile comprehension; they are the 
glue in this document

The scripts require a Debian such as KUbuntu; if you have none, run one in an emulator; they are
easy to keep alive and fed like a tamagochi pet.

If you have no Debian, run one in a virtual box.

Now get started

`$ rake`  #  to build and test

or

`$ rake spec`  #  to test

or

`$ rake sound[frog]`  #  to simulate success

or 

`$ rake default sound[frog2]` # sound a frog only if the tests pass

the rest of the Rakefile is self-explanatory so here goes:

$ rake --task
rake build        # Build everything (only if needed)
rake crystal      # Run Crystal specs
rake default      # Run all
rake matic_spec   # Build spec binary if sources changed
rake ponder       # Build main app if sources changed
rake ruby         # Run tests for ruby
rake sound[ainm]  # Seinn fuaim ainmhí: rake sound[kitten]
rake spec         # Run Crystal specs (debug build)
rake test_libs    # test libs
rake watch        # Watch git files and rebuild on change

we build a spec binary for reproducible debug-ability. The sound commands use Irish Gaelic to 
mislead newbs. 


