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
        {:punct, 3, 4},
        {:punct, 5, 6},
        {:word, 6, 7},
        {:punct, 7, 8},
        {:word, 8, 11},
        {:punct, 11, 12},
        {:punct, 13, 14},
        {:punct, 16, 17},
        {:word, 17, 20},
        {:punct, 20, 21},
        {:punct, 21, 23},
        {:word, 23, 24},
        {:punct, 24, 25},
        {:word, 25, 27},
        {:punct, 27, 28},
        {:word, 28, 29},
        {:punct, 29, 30},
        {:word, 30, 37},
        {:punct, 37, 38},
        {:word, 38, 41},
        {:punct, 41, 42},
        {:word, 42, 47},
        {:punct, 47, 48},
        {:punct, 49, 50},
        {:word, 50, 51},
        {:punct, 51, 52}]
  end

  it "BookGrammar::MAIN parses booklike structures" do
    source = <<-SRC
    This is a sentence.
    And this is
    another sentence.
    SRC

    tokens = Pegmatite.tokenize(BookGrammar::MAIN, source)

    tokens.should eq [{:paragraph, 0, 20},
        {:sentence, 0, 19},
        {:punct, 4, 5},
        {:word, 5, 7},
        {:punct, 7, 8},
        {:word, 8, 9},
        {:punct, 9, 10},
        {:word, 10, 18},
        {:punct, 19, 20},
        {:paragraph, 20, 49},
        {:sentence, 20, 49},
        {:punct, 23, 24},
        {:word, 24, 28},
        {:punct, 28, 29},
        {:word, 29, 31},
        {:punct, 31, 32},
        {:word, 32, 39},
        {:punct, 39, 40},
        {:word, 40, 48}]

#    assert_matches ["yo", "yo"], tokens do |peg|
#      source[peg.peg[1]..(peg.peg[2] - peg.peg[1])]
#    end
# Error: undefined method '[]' for Token

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

      dracula.tokens[0].type.should eq :paragraph  # TODO  parse long spacies as sentence endos

      dracula.tokens[0].value.should eq "The Project Gutenberg eBook of Dracula\r\n" +
       "    \r\n" +
       "This ebook is for the use of anyone anywhere in the United States and\r\n" +
       "most other parts of the world at no cost and with almost no restrictions\r\n" +
       "whatsoever."

      dracula.tokens[0].peg[0].should eq :paragraph
      dracula.tokens[0].peg[1].should eq 3
      dracula.tokens[0].peg[2].should eq 205
      dracula.tokens[1].peg[0].should eq :sentence
      dracula.tokens[1].peg[1].should eq 3
      dracula.tokens[1].peg[2].should eq 205
      dracula.tokens[2].peg[0].should eq :punct
      dracula.tokens[2].peg[1].should eq 6
      dracula.tokens[2].peg[2].should eq 7
      dracula.tokens[3].type.should eq :word
      dracula.tokens[3].value.should eq "Project"  # TODO  values on blanks not needed
      dracula.tokens[4].type.should eq :punct
      dracula.tokens[4].value.should eq " "  #  TODO this should be a lookup into the corpus at the known location
      dracula.tokens[5].type.should eq :word
      dracula.tokens[5].value.should eq "Gutenberg"
      dracula.tokens[6].type.should eq :punct
      dracula.tokens[6].value.should eq " "
      dracula.tokens[7].value.should eq "eBook"
      dracula.tokens[8].value.should eq " "
      dracula.tokens[9].value.should eq "of"
      dracula.tokens[10].value.should eq " "
      dracula.tokens[11].value.should eq "Dracula"
      dracula.tokens[12].value.should eq "\r\n"  # TODO  these define a paragraph
      dracula.tokens[13].value.should eq "\r\n"
      dracula.tokens[14].value.should eq "    "
      dracula.tokens[15].value.should eq "\r\n"
      dracula.tokens[17].value.should eq "This"
      dracula.tokens[17+1].value.should eq " "
      dracula.tokens[18+1].value.should eq "ebook"
      dracula.tokens[19+1].value.should eq " "
      dracula.tokens[20+1].value.should eq "is"
      dracula.tokens[21+1].value.should eq " "
      dracula.tokens[22+1].value.should eq "for"
      dracula.tokens[23+1].value.should eq " "
      dracula.tokens[24+1].value.should eq "the"
      dracula.tokens[50].value.should eq "parts"
      dracula.tokens[51].value.should eq " "

      x = 0

      while dracula.tokens[x].value != "dreams"
        x += 1
      end

      x.should eq 2298
      idx = 2297

      dracula.tokens[idx-8].value.should eq "\r\n"
      dracula.tokens[idx-7].value.should eq "all"
      dracula.tokens[idx-6].value.should eq " "
      dracula.tokens[idx-5].value.should eq "sorts"
      dracula.tokens[idx-4].value.should eq " "
      dracula.tokens[idx-3].value.should eq "of"
      dracula.tokens[idx-2].value.should eq " "
      dracula.tokens[idx-1].value.should eq "queer"
      dracula.tokens[idx].value.should eq " "
      dracula.tokens[idx+1].value.should eq "dreams"
      dracula.tokens[idx+2].value.should eq " "

      dracula.tokens[idx+3].value.should eq(
        "There was a dog howling all night under my\r\n" +
        "window, which may have had something to do with it; or it may have been\r\n" +
        "the paprika, for I had to drink up all the water in my carafe, and was\r\n" +
        "still thirsty.")

      dracula.tokens[idx+4].value.should eq(
        "There was a dog howling all night under my\r\n" +
        "window, which may have had something to do with it; or it may have been\r\n" +
        "the paprika, for I had to drink up all the water in my carafe, and was\r\n" +
        "still thirsty.")

      dracula.tokens[idx+5].value.should eq " "
      dracula.tokens[idx+6].value.should eq "was"
      dracula.tokens[idx+7].value.should eq " "
      dracula.tokens[idx+8].value.should eq "a"
      dracula.tokens[idx+9].value.should eq " "
      dracula.tokens[idx+10].value.should eq "dog"
      dracula.tokens[idx+11].value.should eq " "
      dracula.tokens[idx+12].value.should eq "howling"
      dracula.tokens[idx+13].value.should eq " "
      dracula.tokens[idx+14].value.should eq "all"
      dracula.tokens[idx+15].value.should eq " "
      dracula.tokens[idx+16].value.should eq "night"

      #  now the gospel according to Frankenstein

      frankenstein.tokens[0].type.should eq :punct
      frankenstein.tokens[1].type.should eq :paragraph  # TODO  parse long spacies as sentence endos
      frankenstein.tokens[2].type.should eq :sentence  # TODO  parse long spacies as sentence endos
      frankenstein.tokens[3].type.should eq :punct  # TODO  parse long spacies as sentence endos
      frankenstein.tokens[4].type.should eq :word  # TODO  parse long spacies as sentence endos

      frankenstein.tokens[1].value.should contain(
        "START OF THE PROJECT GUTENBERG EBOOK 84 ***\n" +
        "\n" +
        "Frankenstein;\n" +
        "\n" +
        "or, the Modern Prometheus\n" +
        "\n" +
        "by Mary Wollstonecraft (Godwin) Shelley\n")

      frankenstein.tokens[0].peg[0].should eq :punct
      frankenstein.tokens[0].peg[1].should eq 3
      frankenstein.tokens[0].peg[2].should eq 4

      frankenstein.tokens[1].type.should eq :paragraph
      frankenstein.tokens[1].value.should contain "Chapter 18"
      frankenstein.tokens[2].type.should eq :sentence
      frankenstein.tokens[2].value.should contain "Frankenstein"
      frankenstein.tokens[3].type.should eq :punct
      frankenstein.tokens[3].value.should eq " "
      frankenstein.tokens[4].type.should eq :word
      frankenstein.tokens[4].value.should eq "OF"
      frankenstein.tokens[5].type.should eq :punct
      frankenstein.tokens[5].value.should eq " "

      frankenstein.tokens[1].peg[0].should eq :paragraph
      frankenstein.tokens[1].peg[1].should eq 4
      frankenstein.tokens[1].peg[2].should eq 485
      frankenstein.tokens[50].type.should eq :punct
      yo = 2000

      frankenstein.tokens[yo + 50].value.should eq(
        "My life might have been passed in ease and luxury, but I preferred glory to\n" +
       "every enticement that wealth placed in my path.")

#      frankenstein.tokens[yo + 51].value.should eq "My" # TODO  this should be My!
#      frankenstein.tokens[yo + 52].value.should eq "EBOOK"
#      frankenstein.tokens[yo + 53].value.should eq "EBOOK"
#      frankenstein.tokens[yo + 54].value.should eq "EBOOK"
#      frankenstein.tokens[yo + 55].value.should eq "EBOOK"
#      frankenstein.tokens[yo + 56].value.should eq "EBOOK"
#      frankenstein.tokens[yo + 57].value.should eq "EBOOK"
#      frankenstein.tokens[yo + 58].value.should eq "EBOOK"
#      frankenstein.tokens[yo + 59].value.should eq "EBOOK"
#      frankenstein.tokens[yo + 60].value.should eq "EBOOK"
#      frankenstein.tokens[yo + 61].value.should eq "EBOOK"
#      frankenstein.tokens[yo + 62].value.should eq "EBOOK"
#      frankenstein.tokens[yo + 63].value.should eq "EBOOK"
#      frankenstein.tokens[yo + 64].value.should eq "EBOOK"
#      frankenstein.tokens[yo + 65].value.should eq "EBOOK"

#      boat.tokens[0].type.should eq :sentence  # TODO  parse long spacies as sentence endos
#      boat.tokens[0].value.should eq "The Project Gutenberg eBook, Three Men in a Boat, by Jerome K."
#      boat.tokens[0].peg[0].should eq :sentence
#      boat.tokens[0].peg[1].should eq 3
#      boat.tokens[0].peg[2].should eq 65
#      boat.tokens[1].peg[0].should eq :word
#      boat.tokens[1].peg[1].should eq 7
#      boat.tokens[1].value.should eq "Project"
#      boat.tokens[1].peg[2].should eq 14
#      boat.tokens[1].type.should eq :word
#      boat.tokens[2].type.should eq :word
#      boat.tokens[2].value.should eq "Gutenberg"
#      boat.tokens[3].type.should eq :word
#      boat.tokens[3].value.should eq "eBook"
#      boat.tokens[4].type.should eq :word
#      boat.tokens[4].value.should eq "Three"
#      boat.tokens[5].type.should eq :word
#      boat.tokens[5].value.should eq "Men"
#      boat.tokens[6].value.should eq "Men"
#      boat.tokens[7].value.should eq "Men"
#      boat.tokens[8].value.should eq "Men"
#      boat.tokens[9].value.should eq "Men"
#      boat.tokens[50].value.should eq "Men"
#      boat.tokens[51].value.should eq "Men"
#      boat.tokens[52].value.should eq "Men"
#      boat.tokens[53].value.should eq "Men"
#      boat.tokens[54].value.should eq "Men"
#      boat.tokens[55].value.should eq "Men"
#      boat.tokens[56].value.should eq "Men"
#      # Sentences, Words, and punctuation

      assert_matches(["\r\n",
                             "\r\n",
                             "liver",
                             " ",
                             "complaint",
                             " ",
                             "in",
                             " ",
                             "children",
                             "We agree that we are overworked,\r\n" + "and need rest.",
                             "We agree that we are overworked,\r\n" + "and need rest."],
                        boat.tokens[1000..1010], &.value)

      [dracula.tokens.size, frankenstein.tokens.size, boat.tokens.size].should eq [41773, 37775, 42286]
    end
  end

end  # Error: expecting identifier 'end', not 'EOF

def assert_matches(expected, tokens, &block : Token -> _)
  actual = tokens.map { |t| yield t }
  actual.should eq(expected)
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


