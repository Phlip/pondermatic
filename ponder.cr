require "./lib/crystal-pegmatite/src/pegmatite"

class Token
  property type : Symbol
  property value : String
  property peg : Pegmatite::Token # The raw pegmatite ref

  def initialize(@type, @value, @peg)
  end
end

class BookGrammar
  # Use the DSL.define block to build the pattern tree
  MAIN = Pegmatite::DSL.define do
    # Basic atoms
    low    = range('a', 'z')
    upp    = range('A', 'Z')
    digit  = range('0', '9')
    white  = l(" ") | l("\t") | l("\r") | l("\n")

    # Punctuation and Catch-all
    punct   = l('.') | l(',') | l(':') | l(';') | l('!') | l('?') | l('-') | l('"')
    unknown = any # Non-judgmental fallback

    # Rules
    word           = (upp | low | digit).repeat(1).named(:word)
    sentence_start = upp >> (low | upp | digit).repeat

    # A sentence is a Cap, then anything that isn't terminal punct, then terminal punct
    terminal  = l('.') | l('!') | l('?')
    sentence  = (sentence_start >> (~terminal >> (word | punct | white | unknown)).repeat >> terminal).named(:sentence)

    # Top level entry point
    (sentence | white | word | punct | unknown).repeat.then_eof
  end
end

class Corp
  property filename : String
  property body : String
  property tokens : Array(Token) = [] of Token
  LIMIT = 150_000

  def self.parseFolder(path : String) : Array(Corp)
    results = [] of Corp

    Dir.glob("#{path}/*.txt").each do |file|
      next unless File.file?(file)

      # Inside your loop
      # .head(n) is safe: it returns at most n characters, handling UTF-8 boundaries
      content = File.read(file, encoding: "UTF-8", invalid: :skip)[0...LIMIT]
      results << Corp.new(file, content)
    end

    results.sort_by! { |c| File.basename(c.filename) }
    return results
  end

  def initialize(@filename : String, @body : String)
    # --- Token easter ---
    # Very simple Pegmatite-style tokenizer: words, punctuation, quotes
    # Inside your initializer

    # result = Pegmatite.tokenize(BookGrammar::MAIN, @body)

    begin
      result = Pegmatite.tokenize(BookGrammar::MAIN, @body)

      @tokens = result.compact_map do |p_tuple|
        # p_tuple is {Symbol, Int32, Int32}
        next if p_tuple[0] == :ignored

        # Index 1 is offset, Index 2 is length (or end offset depending on Pegmatite version)
        val = @body.byte_slice(p_tuple[1], p_tuple[2])
        Token.new(p_tuple[0], val, p_tuple)
      end

    rescue ex : Pegmatite::Pattern::MatchError
      puts "Failed to parse: #{ex.message}"
    end
  end

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
