class BalancedTernary
  include Comparable(BalancedTernary)

  getter digits : String

  def initialize(str = "")
    if str =~ /[^-+0]+/
      raise ArgumentError.new("invalid BalancedTernary number: #{str}")
    end
    @digits = trim0(str)
  end

  I2BT = {0 => {"0", 0}, 1 => {"+", 0}, 2 => {"-", 1}}

  def self.from_int(value : Int)
    n = value
    digits = ""
    while n != 0
      quo, rem = n.divmod(3)
      bt, carry = I2BT[rem]
      digits = bt + digits
      n = quo + carry
    end
    new(digits)
  end

  BT2I = {"-" => -1, "0" => 0, "+" => 1}

  def to_i
    @digits.each_char.reduce(0) do |sum, char|
      3 * sum + BT2I[char.to_s]
    end
  end

  def to_s
    @digits.dup
  end

  def <=>(other)
    to_i <=> other.to_i
  end

  ADDITION_TABLE = {
  "---" => {"-", "0"}, "--0" => {"-", "+"}, "--+" => {"0", "-"},
  "-0-" => {"-", "+"}, "-00" => {"0", "-"}, "-0+" => {"0", "0"},
  "-+-" => {"0", "-"}, "-+0" => {"0", "0"}, "-++" => {"0", "+"},
  "0--" => {"-", "+"}, "0-0" => {"0", "-"}, "0-+" => {"0", "0"},
  "00-" => {"0", "-"}, "000" => {"0", "0"}, "00+" => {"0", "+"},
  "0+-" => {"0", "0"}, "0+0" => {"0", "+"}, "0++" => {"+", "-"},
  "+--" => {"0", "-"}, "+-0" => {"0", "0"}, "+-+" => {"0", "+"},
  "+0-" => {"0", "0"}, "+00" => {"0", "+"}, "+0+" => {"+", "-"},
  "++-" => {"0", "+"}, "++0" => {"+", "-"}, "+++" => {"+", "0"},
  }

  def +(other)
    maxl = {to_s.size, other.to_s.size}.max
    a = pad0_reverse(to_s, maxl)
    b = pad0_reverse(other.to_s, maxl)
    carry = "0"
    sum = ""

    a.zip(b).each do |c1, c2|
      carry, digit = ADDITION_TABLE[carry + c1 + c2]
      sum = digit + sum
    end

    self.class.new(carry + sum)
  end

  MULTIPLICATION_TABLE = {
  "-" => "+0-",
  "0" => "000",
  "+" => "-0+",
  }

  def *(other)
    product = self.class.new
    other.to_s.each_char do |bdigit|
      row = to_s.tr("-0+", MULTIPLICATION_TABLE[bdigit.to_s])
      product += self.class.new(row)
      product << 1
    end
    product >> 1
  end

  def negate
    self.class.new(@digits.tr("-+", "+-"))
  end

  def -(other)
    self + other.negate
  end

  def <<(count)
    @digits = trim0(@digits + "0" * count)
    self
  end

  def >>(count)
    if count > 0
      @digits = @digits[0, @digits.size - count]? || ""
    end
    @digits = trim0(@digits)
    self
  end

  private def trim0(str)
    s = str.sub(/^0+/, "")
      s = "0" if s.empty?
    s
  end

  private def pad0_reverse(str, len)
    str.rjust(len, '0').reverse.chars.map(&.to_s)
  end
end
