# An argument held as its String's handle, read by the arm a boxed
# receiver's `new` takes for any class value (emit_poly_cls_value_builtin),
# was bound as the handle where the arm read the String's bytes: the C
# initialized a `const char *` from an `sp_String *` and the build stopped.
# The pieces that lead there: `k[x]` on a box that may hold a Data class is
# that class's `new` (Key); a Set's `self.[](*args)` takes the argument into
# a rest whose Strings the rule shares (Sink's buffer reaches it), so the
# argument is held as its handle; a module's own `self.new` (Maker) and an
# instance method named `new` (Thing) make that `new` a boxed dispatch.
require "set"

Key = Data.define(:digest)

module Maker
  def self.new = "made"
end

class Thing
  def new = self
end

class Sink
  def initialize = @buf = String.new
  def <<(s)
    @buf << s
    flush(@buf)
    self
  end
  def seen = Set[@buf]
end

def look(box, name)
  box[name.to_s.downcase]
end

boxes = [{ "ab" => 1 }, Set, Key, Maker]
p look(boxes[0], :AB)
p look(boxes[1], "CD")
p look(boxes[2], :EF)
p Maker.new
p Thing.new.new.class
