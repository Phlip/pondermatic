require "spec"
require "./ponder"
require "./lib/crystal-pegmatite/spec/fixtures/*"

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


# ddd_break  # TODO  debug me


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

      frankenstein.tokens[0].type.should eq :sentence  # TODO  parse long spacies as sentence endos
      frankenstein.tokens[0].value.should contain("START OF THE PROJECT GUTENBERG EBOOK 84 ***\n" +
       "\n" +
       "Frankenstein;\n" +
       "\n" +
       "or, the Modern Prometheus\n" +
       "\n" +
       "by Mary Wollstonecraft (Godwin) Shelley\n")
      frankenstein.tokens[0].peg[0].should eq :sentence
      frankenstein.tokens[0].peg[1].should eq 4
      frankenstein.tokens[0].peg[2].should eq 485
      frankenstein.tokens[1].type.should eq :word
      frankenstein.tokens[1].value.should eq "OF THE PROJE"
      frankenstein.tokens[1].peg[0].should eq :word
      frankenstein.tokens[1].peg[1].should eq 10
      frankenstein.tokens[1].peg[2].should eq 12
      frankenstein.tokens[1].type.should eq :word
      frankenstein.tokens[2].value.should eq "THE PROJECT GUTE"
      frankenstein.tokens[2].type.should eq :word
      frankenstein.tokens[3].type.should eq :word
      frankenstein.tokens[3].value.should eq "PROJECT GUTENBERG EBOOK "
      frankenstein.tokens[4].type.should eq :word
      frankenstein.tokens[4].value.should eq "GUTENBERG EBOOK 84 ***\n" + "\n" + "Frankenste"
      frankenstein.tokens[5].type.should eq :word
      frankenstein.tokens[5].value.should eq "EBOOK 84 ***\n" + "\n" + "Frankenstein;\n" + "\n" + "or, the Mod"

      boat.tokens[0].type.should eq :sentence  # TODO  parse long spacies as sentence endos
      boat.tokens[0].value.should eq "The Project Gutenberg eBook, Three Men in a Boat, by Jerome K. Je"
      boat.tokens[0].peg[0].should eq :sentence
      boat.tokens[0].peg[1].should eq 3
      boat.tokens[0].peg[2].should eq 65
      boat.tokens[1].peg[0].should eq :word
      boat.tokens[1].peg[1].should eq 7
      boat.tokens[1].value.should eq "Project Gutenb"
      boat.tokens[1].peg[2].should eq 14
      boat.tokens[1].type.should eq :word
      boat.tokens[2].type.should eq :word
      boat.tokens[2].value.should eq "Gutenberg eBook, Three M"
      boat.tokens[3].type.should eq :word
      boat.tokens[3].value.should eq "eBook, Three Men in a Boat, by"
      boat.tokens[4].type.should eq :word
      boat.tokens[4].value.should eq "Three Men in a Boat, by Jerome K. Jer"
      boat.tokens[5].type.should eq :word
      boat.tokens[5].value.should eq "Men in a Boat, by Jerome K. Jerome\r\n" + "\r\n" + "Thi"

    end
  end

  it "Fixtures::HeredocGrammar parses heredoc-like structures" do
    source = <<-SRC
    one = 1
    two = <<-TWO
      I am a heredoc
    TWO
    three = 3

    SRC

    tokens = Pegmatite.tokenize(Fixtures::HeredocGrammar, source)

    tokens.should eq [
      {:attribute, 0, 8},
      {:identifier, 0, 3}, # one
      {:number, 6, 7},     # 1
      {:attribute, 8, 42},
      {:identifier, 8, 11}, # two
      {:heredoc, 14, 41},
      {:identifier, 17, 20}, # TWO
      {:string, 21, 38},     # "  I am a heredoc\n"
      {:identifier, 38, 41}, # TWO
      {:attribute, 42, 52},
      {:identifier, 42, 47}, # three
      {:number, 50, 51},     # 3
    ]
  end

  it "BookGrammar::MAIN parses heredoc-like structures" do
    source = <<-SRC
    one = 1
    two = <<-TWO
      I am a heredoc
    TWO
    three = 3

    SRC

    tokens = Pegmatite.tokenize(BookGrammar::MAIN, source)

    tokens.should eq [{:word, 0, 3},
        {:word, 6, 7},
        {:word, 8, 11},
        {:word, 17, 20},
        {:word, 23, 24},
        {:word, 25, 27},
        {:word, 28, 29},
        {:word, 30, 37},
        {:word, 38, 41},
        {:word, 42, 47},
        {:word, 50, 51}]
  end

  it "BookGrammar::MAIN parses booklike structures" do
    source = <<-SRC
    This is a sentence.
    And this is
    another sentence.
    SRC

    tokens = Pegmatite.tokenize(BookGrammar::MAIN, source)

    tokens.should eq [{:sentence, 0, 19},
        {:word, 5, 7},
        {:word, 8, 9},
        {:word, 10, 18},
        {:sentence, 20, 49},
        {:word, 24, 28},
        {:word, 29, 31},
        {:word, 32, 39},
        {:word, 40, 48}]
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


