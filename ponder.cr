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
    low = range('a', 'z') # Basic atoms
    upp = range('A', 'Z')
    digit = range('0', '9')
    blank = l(" ")
    collapsed = blank.repeat(1).named(:punct) # This captures a run of 1 or more spaces as a single token & saves cognitive room by identifying as a punct

    # Define CRLF (carriage return + linefeed) as a single unit
    cr = l("\r") # carriage return alone
    lf = l("\n") # linefeed alone
    crlf = (cr >> lf).named(:punct)

    # Individual line breaks
    brk = (crlf | cr | lf).named(:punct)
    white = collapsed | l("\t") | brk
    dot = l('.')
    bang = l('!')
    query = l('?')

    # Punctuation and Catch-all
    terminal = dot | bang | query
    punct = terminal | l(',') | l(':') | l(';') | l('-') | l('"') | l('\'')
    punct = punct.named(:punct)
    unknown = any # Non-judgmental fallback

    # Rules
    word = (upp | low | digit).repeat(1).named(:word)
    sentence_start = (upp >> (low | upp | digit).repeat).named(:word)

    # A sentence is a Cap, then anything that isn't terminal punct, then terminal punct
    sentence = (sentence_start >> (~terminal >> (word | punct | white | unknown)).repeat >> terminal.named(:punct)).named(:sentence)
    paragraph = (sentence.repeat(1) >> brk.maybe).named(:paragraph)

    # Top level entry point
    (paragraph | sentence | white | word | punct | unknown).repeat.then_eof
  end
end

class Frob

  def initialize(type : Symbol, value : String)
    @type = type
    @value = value
    @count = 0
  end

  property type : Symbol
  property value : String
  property count : Int32
  @@frobs = {} of String => Frob

  def self.token_assessor(token : Token)
    key = token.value
    frob = @@frobs[key]?

    unless frob
      frob = Frob.new(token.type, token.value)
      @@frobs[key] = frob
    end

    frob.count += 1
  end

  def self.frobs
    return @@frobs.values
  end

end

class Corp
  property filename : String
  property body : String
  property tokens : Array(Token) = [] of Token

  def self.parseFolder(path : String, bytes_of_books_we_need_read : Int128) : Array(Corp)
    results = [] of Corp

    Dir.glob("#{path}/*.txt").each do |file|
      next unless File.file?(file)

      # Inside your loop
      # .head(n) is safe: it returns at most n characters, handling UTF-8 boundaries

      content = File.read(file, encoding: "UTF-8", invalid: :skip)[0...bytes_of_books_we_need_read]
      results << Corp.new(file, content)
    end

    results.sort_by! { |c| File.basename(c.filename) }
    return results
  end

  def initialize(@filename : String, @body : String)
    begin
      result = Pegmatite.tokenize(BookGrammar::MAIN, @body)

      # TODO  move the token_assessor() inside the tokenizer to then devour its soul

      @tokens = result.compact_map do |p_tuple|

        # p_tuple is {Symbol, Int32, Int32}

        next if p_tuple[0] == :ignored

        # Index 1 is offset, Index 2 is length (or end offset depending on Pegmatite version)

        token_length = p_tuple[2] - p_tuple[1]
        val = @body.byte_slice(p_tuple[1], token_length)
        newb = Token.new(p_tuple[0], val, p_tuple)
        Frob.token_assessor(newb)
        newb
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
