# spinel: needs-rbs-parser
# String#unpack1 with a literal String directive answers a new String, so a
# method answering one (OpenSSL::Digest#hexdigest, and #to_s over it) is
# typed String. Left untyped, it made every boxed `x.to_s` in the program
# reach an untyped arm, and a program that also changes a String in place
# was refused with #9258 (#9982).
require "uri"

class Hex
  def initialize(raw) = @raw = raw
  def hexdigest = @raw.unpack1("H*")
  def to_s = hexdigest
end

class Sink
  def initialize
    @buf = String.new
  end

  def <<(s)
    @buf << s
    flush(@buf)
    self
  end

  def flush(s) = s.bytesize
end

module Links
  #: (untyped url) -> String?
  def self.link(url)
    begin
      URI.parse(url).to_s
    rescue
      nil
    end
  end
end

fx = Links.link(["https://x.com/a", 1][ARGV.size])
p fx
fx = Links.link(1)
p fx

p Hex.new("ab\x01").to_s
p Hex.new("").to_s
h = Hex.new("\xff").hexdigest
h << "!"
p h
sink = Sink.new
sink << "x"

data = "ab\x01"
p data.unpack1("a")
p data.unpack1("A2")
p data.unpack1("Z*")
p data.unpack1("B*")
p data.unpack1("b*")
p data.unpack1("h*")
p data.unpack1("H")
p data.unpack1("H*", offset: 1)
p "aGk=\n".unpack1("m")
p "aGk=".unpack1("m0")
p "=41=42\n".unpack1("M")
p "".unpack1("u")
p data.unpack1("H*").upcase

# On a boxed receiver the answer stays boxed, beside a user class's own
# unpack1.
class Pk
  def unpack1(f) = 42
end
x = ["ab\x01", Pk.new][0]
s = x.unpack1("H*")
s << "!"
p s
p x.unpack1("a2", offset: 1)
p ["ab", Pk.new][1].unpack1("H*")
