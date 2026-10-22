# String#unpack1 with a literal single-directive format: the directive fixes
# the extracted value's type, so the result no longer stays poly. Doom's WAD
# reader depends on this for header fields: `@num_lumps = data[4, 4].unpack1('V')`
# then `@num_lumps.times.map { ... }`.
data = [7, 300].pack('V2')
n = data.unpack1('V')
p n
p n.times.map { |i| i * 2 }
p data[4, 4].unpack1('V')
p [-2].pack('s<').unpack1('s<')
p [65534].pack('v').unpack1('v')
p [200].pack('C').unpack1('C')

# A non-literal format stays on the boxed path.
fmt = 'V'
p data.unpack1(fmt)

# A multi-directive format keeps the boxed poly result; a String directive
# answers a String.
p data.unpack1('VV')
p "ABCD".unpack1('a4').length

# Doom's directory shape: a count read via unpack1 drives times.map into a
# poly-array ivar that is later mutated.
class Hdr
  attr_reader :items

  def initialize(raw)
    @count = raw.unpack1('V')
    @items = @count.times.map { |i| i.even? ? i : "s#{i}" }
  end

  def add(x)
    @items << x
  end
end

h = Hdr.new([3].pack('V'))
h.add("s")
p h.items
