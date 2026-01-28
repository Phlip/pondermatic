require "spec"
require "./ponder"

describe Corp do
  describe ".parseFolder" do
    it "finds matching files in ./corpus and returns Corp objects with filename and body" do
      results = Corp.parseFolder("./corpus")

      results.should be_a(Array(Corp))
      results.size.should be > 0

      results[0].filename.should eq "./corpus/dracula.txt"
      results[1].filename.should eq "./corpus/frankenstein.txt"
      results[2].filename.should eq "./corpus/three_men_in_a_boat.txt"

      filenames = results.map(&.filename)
      bodies = results.map(&.body)

      filenames.any? { |f| f.includes?(".txt") }.should be_true

      assert_substring "and he said it was called “paprika hendl,”", bodies[0]
      assert_substring "or, the Modern Prometheus", bodies[1]
      assert_substring "Title: Three Men in a Boat", bodies[2]
      bodies[0].includes?("and he said it was called “paprika hendl,”").should be_true
      bodies[1].includes?("or, the Modern Prometheus").should be_true
      bodies[2].includes?("Title: Three Men in a Boat").should be_true
    end
  end

  describe ".parseFolder() with Pegmatite" do
    it "tokenizes book text into words and punctuation tokens" do

# TODO  debug me      ddd_break


      results = Corp.parseFolder("./corpus")

      dracula = results[0]
      frankenstein = results[1]
      boat = results[2]

      dracula.tokens.should_not be_empty
      frankenstein.tokens.should_not be_empty
      boat.tokens.should_not be_empty

      # Words
      dracula.tokens.size.should eq 28237
      frankenstein.tokens.size.should eq 26711
      boat.tokens.size.should eq 28059

      dracula.tokens[0].type.should eq :sentence  # TODO  parse long spacies as sentence endos
      dracula.tokens[0].value.should eq "The Project Gutenberg eBook of Dracula\r\n    \r\nThis ebook is for the use of anyone anywhere in the United States and\r\nmost other parts of the world at no cost and with almost no restrictions\r\nwhatsoever. Yo"
      dracula.tokens[0].peg[0].should eq :sentence
      dracula.tokens[0].peg[1].should eq 3
      dracula.tokens[0].peg[2].should eq 205
      dracula.tokens[1].peg[0].should eq :word
      dracula.tokens[1].peg[1].should eq 7
      dracula.tokens[1].peg[2].should eq 14
      dracula.tokens[1].type.should eq :word
      dracula.tokens[1].value.should eq "Project Gutenb"
      dracula.tokens[2].type.should eq :word
      dracula.tokens[2].value.should eq "Gutenberg eBook of Dracu"  #  TODO this should be a lookup into the corpus at the known location
      # # dracula.tokens[1][0][0].should eq :yo
      # dracula.tokens[1][0][1].should eq 0
      # dracula.tokens[1][0][2].should eq 1
      # dracula.tokens[2][0][0].should eq :yo
      # dracula.tokens[2][0][1].should eq 0
      # dracula.tokens[2][0][2].should eq 1

    end
  end

end

def assert_substring(reference : String, sample : String, swatch_size = 40)
  return if sample.includes?(reference)

  # Provide context: show the start of the sample or a truncated version
  swatch = sample.size > swatch_size ? "#{sample[0...swatch_size]}..." : sample

  fail <<-ERROR
  Expected substring missing:
    Expected: #{reference.inspect}
    In sample: #{swatch.inspect}
    (Full sample size: #{sample.size} bytes)
  ERROR
end

# Use the C library approach for maximum compatibility
@[Link("c")]
lib LibC
  fun raise(sig : Int32) : Int32
  SIG_TRAP = 5
end

def ddd_break
  LibC.raise(LibC::SIG_TRAP)
end
