require "spec"
require "./ponder"
require "./lib/crystal-pegmatite/spec/fixtures/*"
require "./balanced_ternary"

describe Corp do

  before_each do
    Frob.reset
  end

  it "Frob stores offerings and reports their tallies" do
    Frob.token_assessor(Token.new(:word, "apple", {:word, 0, 5}))
    Frob.token_assessor(Token.new(:word, "banana", {:word, 6, 12}))
    Frob.token_assessor(Token.new(:word, "apple", {:word, 13, 18}))

    frobs = Frob.frobs

    frobs.size.should eq 2
    frobs[0].value.should eq "apple"
    frobs[0].count.should eq 2
    frobs[1].value.should eq "banana"
    frobs[1].count.should eq 1
  end

  it "frob accumulation counts occurrences by value across the stream" do
    bytes_of_books_we_need_read_in_this_test = 50_000

    frobs = arrange_frobbed_corpus(bytes_of_books_we_need_read_in_this_test)

    frobs.should_not be_empty
    frobs[0].value.should eq "\n"
    frobs[0].type.should eq :punct
    frobs[0].count.should eq 924
    frobs[1].value.should eq "\r\n"
    frobs[1].count.should eq 3870
    frobs[2].value.should eq " "  #  yes the lowly space is a mighty Frob
    frobs[2].count.should eq 24_484
    frobs[3].value.should eq "    " # contain("START OF THE PROJECT GUTENBERG EBOOK 84 ***\n\n")
    frobs[4].value.should eq "     "
    frobs[5].value.should eq "      "
    frobs[6].value.should eq "       "
    frobs[7].value.should eq "             "
    frobs[8].value.should eq "               "
    frobs[9].value.should eq "                "
    frobs[42].value.should eq "17"
    frobs[43].value.should eq "18"
    frobs[44].value.should eq "1889"
    frobs[1001].value.should eq "If"
    frobs[1].type.should eq :punct
    frobs[1].type.should eq :punct
    frobs[2].type.should eq :punct
    frobs[3].type.should eq :punct
    frobs[4].type.should eq :punct
    frobs[42].type.should eq :word
    frobs[43].type.should eq :word
    frobs[44].type.should eq :word
    frobs[1001].type.should eq :word
    frobs[1].count.should eq 3870
    frobs[2].count.should eq 24484
    frobs[3].count.should eq 8
    frobs[4].count.should eq 6
  end

  it "finds matching files in ./corpus and returns Corp objects with filename and body" do
    results = Corp.parseFolder("./corpus", 100_000)

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

    # a heredoc inside a heredoc, folks!

    source = <<-SRC
    one = 1
    two = <<-TWO
      I am a heredoc
    TWO
    three = 3

    SRC

    # TODO  get inside the tokenizer and use ONE PASS

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

    ["This is a sentence.\n",
    "This is a sentence.",
    "This",
    " ",
    "is",
    " ",
    "a",
    " ",
    "sentence",
    ".",
    "\n",
    "And this is\n" + "another sentence.",
    "And this is\n" + "another sentence.",
    "And",
    " ",
    "this",
    " ",
    "is",
    "\n",
    "another",
    " ",
    "sentence",
    "."].should eq(
    assert_spun(tokens){|t| source[t[1]...t[2]] })

    tokens.should eq [{:paragraph, 0, 20},
    {:sentence, 0, 19},
    {:word, 0, 4},
    {:punct, 4, 5},
    {:word, 5, 7},
    {:punct, 7, 8},
    {:word, 8, 9},
    {:punct, 9, 10},
    {:word, 10, 18},
    {:punct, 18, 19},
    {:punct, 19, 20},
    {:paragraph, 20, 49},
    {:sentence, 20, 49},
    {:word, 20, 23},
    {:punct, 23, 24},
    {:word, 24, 28},
    {:punct, 28, 29},
    {:word, 29, 31},
    {:punct, 31, 32},
    {:word, 32, 39},
    {:punct, 39, 40},
    {:word, 40, 48},
    {:punct, 48, 49}]
  end

  it "Frobs know their Next Frobs" do
    Frob.frobs.size.should eq 0
    source = "This is a sentence.\nAnd this is another sentence."

    corp = Corp.new("yo", source)

    Frob.frobs.size.should eq 13
    frobs = Frob.frobs
    frobs = frobs.sort_by(&.value)
    frobs[0].value.should eq "\n"
    frobs[0].type.should eq :punct
    idx = 0
    frobs[idx += 1].value.should eq " "
    frobs[idx].type.should eq :punct
    frobs[idx].count.should eq 7
    frobs[idx += 1].value.should eq "."
    frobs[idx].type.should eq :punct
    frobs[idx].count.should eq 2
    frobs[idx += 1].value.should eq "And"
    frobs[idx].type.should eq :word
    frobs[idx].count.should eq 1
    frobs[idx += 1].value.should eq "And this is another sentence."
    frobs[idx].type.should eq :paragraph
    frobs[idx].count.should eq 2

    #  and now we pass these assertions!

    frobs[idx += 1].value.should eq "This"
    frobs[idx].type.should eq :word
    frobs[idx].count.should eq 1
    frobs[idx += 1].value.should eq "This is a sentence."
    frobs[idx].type.should eq :sentence
    frobs[idx].count.should eq 1
    frobs[idx += 1].value.should eq "This is a sentence.\n"
    frobs[idx].type.should eq :paragraph
    frobs[idx].count.should eq 1
    frobs[idx += 1].value.should eq "a"
    frobs[idx].type.should eq :word
    frobs[idx].count.should eq 1
    frobs[idx += 1].value.should eq "another"
    frobs[idx].count.should eq 1
    frobs[idx].type.should eq :word
    frobs[idx += 1].value.should eq "is"
    frobs[idx].count.should eq 2
    frobs[idx].type.should eq :word
    frobs[idx].next_frobs.size.should eq 1
    frobs[idx].next_frobs.values[0].frob.value.should eq " "
    frobs[idx].next_frobs.values[0].valence.should eq 1.0
    frobs[idx].next_frobs.values[0].frob.next_frobs["a"].frob.value.should eq "a"
    frobs[idx].next_frobs.values[0].frob.next_frobs.values[0].valence.should eq 1.0
    frobs[idx].next_frobs.values[0].frob.next_frobs["another"].frob.value.should eq "another"
    frobs[idx].next_frobs.values[0].frob.next_frobs.values[1].valence.should eq 1.0
    frobs[idx].next_frobs.values[0].frob.next_frobs["is"].frob.value.should eq "is"
    frobs[idx].next_frobs.values[0].frob.next_frobs.values[2].valence.should eq 1.0
    frobs[idx].next_frobs.values[0].frob.next_frobs["sentence"].frob.value.should eq "sentence"
    frobs[idx].next_frobs.values[0].frob.next_frobs.values[3].valence.should eq 1.0
    frobs[idx].next_frobs.values[0].frob.next_frobs["this"].frob.value.should eq "this"
    frobs[idx].next_frobs.values[0].frob.next_frobs.values[4].valence.should eq 1.0
    frobs[idx].next_frobs.values[0].frob.next_frobs.values.size.should eq 5
    frobs[idx += 1].value.should eq "sentence"
    frobs[idx].type.should eq :word
    frobs[idx].count.should eq 2
    frobs[idx].next_frobs.size.should eq 1
    frobs[idx].next_frobs.values[0].frob.value.should eq "."
    frobs[idx].next_frobs.values[0].valence.should eq 1.0
    frobs[idx += 1].value.should eq "this"
    frobs[idx].type.should eq :word
    frobs[idx].count.should eq 1
    idx.should eq 12
  end

  it ".parseFolder() with Pegmatite .parseFolder() with Pegmatite tokenizes book text into words and punctuation tokens" do

    # ddd_break  # TODO  debug me

    results = Corp.parseFolder("./corpus", 100_000)

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

    dracula.tokens[2].value.should eq "The"
    dracula.tokens[2].peg[0].should eq :word
    dracula.tokens[2].peg[1].should eq 3
    dracula.tokens[2].peg[2].should eq 6
    idx = 1
    dracula.tokens[idx + 2].peg[0].should eq :punct
    dracula.tokens[idx + 2].peg[1].should eq 6
    dracula.tokens[idx + 2].peg[2].should eq 7
    dracula.tokens[idx + 3].type.should eq :word
    dracula.tokens[idx + 3].value.should eq "Project"  # TODO  values on blanks not needed
    dracula.tokens[idx + 4].type.should eq :punct
    dracula.tokens[idx + 4].value.should eq " "  #  TODO this should be a lookup into the corpus at the known location
    dracula.tokens[idx + 5].type.should eq :word
    dracula.tokens[idx + 5].value.should eq "Gutenberg"
    dracula.tokens[idx + 6].type.should eq :punct
    dracula.tokens[idx + 6].value.should eq " "
    dracula.tokens[idx + 7].value.should eq "eBook"
    dracula.tokens[idx + 8].value.should eq " "
    dracula.tokens[idx + 9].value.should eq "of"
    dracula.tokens[idx + 10].value.should eq " "
    dracula.tokens[idx + 11].value.should eq "Dracula"
    dracula.tokens[idx + 12].value.should eq "\r\n"  # TODO  these define a paragraph
    dracula.tokens[idx + 13].value.should eq "\r\n"
    dracula.tokens[idx + 14].value.should eq "    "
    dracula.tokens[idx + 15].value.should eq "\r\n"
    dracula.tokens[idx + 17].value.should eq "This"
    dracula.tokens[idx + 17+1].value.should eq " "
    dracula.tokens[idx + 18+1].value.should eq "ebook"
    dracula.tokens[idx + 19+1].value.should eq " "
    dracula.tokens[idx + 20+1].value.should eq "is"
    dracula.tokens[idx + 21+1].value.should eq " "
    dracula.tokens[idx + 22+1].value.should eq "for"
    dracula.tokens[idx + 23+1].value.should eq " "
    dracula.tokens[idx + 24+1].value.should eq "the"
    dracula.tokens[50].value.should eq " "
    dracula.tokens[51].value.should eq "parts"

    x = 0

    while dracula.tokens[x].value != "dreams"
      x += 1
    end

    x.should eq 2445  #  if you change this, change the next assignment to be one less
    idx = 2444
    idx.should eq x - 1

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
    dracula.tokens[idx+2].value.should eq "."
    dracula.tokens[idx+3].value.should eq " "

    dracula.tokens[idx+4].value.should eq(
      "There was a dog howling all night under my\r\n" +
      "window, which may have had something to do with it; or it may have been\r\n" +
      "the paprika, for I had to drink up all the water in my carafe, and was\r\n" +
      "still thirsty.")

    idx -= 1
    dracula.tokens[idx+4].value.should eq " "
    dracula.tokens[idx+5].value.should eq "There was a dog howling all night under my\r\n" +
                                                 "window, which may have had something to do with it; or it may have been\r\n" +
                                                 "the paprika, for I had to drink up all the water in my carafe, and was\r\n" +
                                                 "still thirsty."
    dracula.tokens[idx+6].value.should eq "There was a dog howling all night under my\r\n" +
                                                 "window, which may have had something to do with it; or it may have been\r\n" +
                                                 "the paprika, for I had to drink up all the water in my carafe, and was\r\n" +
                                                 "still thirsty."
    dracula.tokens[idx+7].value.should eq "There"
    dracula.tokens[idx+8].value.should eq " "
    dracula.tokens[idx+9].value.should eq "was"
    dracula.tokens[idx+10].value.should eq " "
    dracula.tokens[idx+11].value.should eq "a"
    dracula.tokens[idx+12].value.should eq " "
    dracula.tokens[idx+13].value.should eq "dog"
    dracula.tokens[idx+14].value.should eq " "
    dracula.tokens[idx+15].value.should eq "howling"
    dracula.tokens[idx+16].value.should eq " "
    dracula.tokens[idx+17].value.should eq "all"
    dracula.tokens[idx+18].value.should eq " "
    dracula.tokens[idx+19].value.should eq "night"

    #  now the gospel according to Frankenstein

    frankenstein.tokens[0].type.should eq :punct
    frankenstein.tokens[1].type.should eq :paragraph
    frankenstein.tokens[2].type.should eq :sentence
    frankenstein.tokens[3].type.should eq :word
    frankenstein.tokens[4].type.should eq :punct
    frankenstein.tokens[5].type.should eq :word

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
    frankenstein.tokens[3].type.should eq :word
    frankenstein.tokens[1].peg[1].should eq 4
    frankenstein.tokens[1].peg[2].should eq 485
    frankenstein.tokens[2].peg[1].should eq 4
    frankenstein.tokens[2].peg[2].should eq 485
    frankenstein.tokens[50].type.should eq :word
    frankenstein.tokens[51].type.should eq :punct
    frankenstein.tokens[52].type.should eq :word
    frankenstein.tokens[53].type.should eq :punct
    yo = 2000

#      frankenstein.tokens[yo + 50].value.should eq(
#        "My life might have been passed in ease and luxury, but I preferred glory to\n" +
#       "every enticement that wealth placed in my path.")

#      boat.tokens[0].type.should eq :sentence  # TODO  parse long spacies as sentence endos

    assert_spun(boat.tokens[1000..1020], &.value).should eq [
      ".",
      "\r\n",
      "\r\n",
      "\r\n",
      "\r\n",
      "\r\n",
      "\r\n",
      "Three invalids.",
      "Three invalids.",
      "Three",
      " ",
      "invalids",
      ".",
      "Sufferings of George and Harris.",
      "Sufferings of George and Harris.",
      "Sufferings",
      " ",
      "of",
      " ",
      "George",
      " "]

    assert_spun(boat.tokens[10000..10020], &.value).should eq [  #  to be read in a snippy, camp, Toft, nasal voice
      " ",
      "Harris\r\n" +
      "and I would go down in the morning, and take the boat up to Chertsey,\r\n" +
      "and George, who would not be able to get away from the City till the\r\n" +
      "afternoon (George goes to sleep at a bank from ten to four each day,\r\n" +
      "except Saturdays, when they wake him up and put him outside at two),\r\n" +
      "would meet us there.\r\n",
      "Harris\r\n" +
      "and I would go down in the morning, and take the boat up to Chertsey,\r\n" +
      "and George, who would not be able to get away from the City till the\r\n" +
      "afternoon (George goes to sleep at a bank from ten to four each day,\r\n" +
      "except Saturdays, when they wake him up and put him outside at two),\r\n" +
      "would meet us there.",
      "Harris",
      "\r\n",
      "\r\n",
      "and",
      " ",
      "I",
      " ",
      "would",
      " ",
      "go",
      " ",
      "down",
      " ",
      "in",
      " ",
      "the",
      " ",
      "morning"
    ]

    [dracula.tokens.size, frankenstein.tokens.size, boat.tokens.size
          ].should eq [43489, 39271, 44166]
  end

  it "BalancedTernary handles Benito's trio" do
    a = BalancedTernary.new("+-0++0+")
    b = BalancedTernary.from_int(-436)
    c = BalancedTernary.new("+-++-")

    a.to_s.should eq("+-0++0+")
    a.to_i.should eq(523)

    b.to_s.should eq("-++-0--")
    b.to_i.should eq(-436)

    c.to_s.should eq("+-++-")
    c.to_i.should eq(65)
  end

  it "performs the world tour finale" do
    a = BalancedTernary.new("+-0++0+")
    b = BalancedTernary.from_int(-436)
    c = BalancedTernary.new("+-++-")

    r = a * (b - c)

    r.to_s.should eq("----0+--0++0")
    r.to_i.should eq(-262_023)
  end

end  # Error: expecting identifier 'end', not 'EOF

def arrange_frobbed_corpus(bytes_of_books_we_need_read)
  results = Corp.parseFolder("./corpus", bytes_of_books_we_need_read)

  results.should be_a(Array(Corp))
  results.size.should be > 0

  results[0].filename.should eq "./corpus/dracula.txt"
  results[1].filename.should eq "./corpus/frankenstein.txt"
  results[2].filename.should eq "./corpus/three_men_in_a_boat.txt"
  return Frob.frobs.sort_by{|f| f.value }   # asciibetic, brute force, test-only
end  #  You trained an ethical AI on gothic horror and a gay victorian didactic romcom novel??

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

def assert_spun(tokens, &block)
  count = 0
  tokens_size = tokens.size

  result = tokens.map do |t|
    count += 1
    yield t
  end

  # Verify we processed all tokens
  unless count == tokens_size && count == tokens.size
    raise "Expected to process #{tokens_size} tokens but only did #{count} and actual count is #{tokens.size}"
  end

  result
end
