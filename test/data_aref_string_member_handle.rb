# `k[x]` on a boxed receiver that may hold a Data class is that class's
# `new`. A String argument fills a String member as its bytes or as its
# handle; a member whose String the rule shares (it is held as a handle)
# beside an argument read as bytes was taken as another type, the class's
# arm was dropped, and `Key["cd"]` answered nil.
Key = Data.define(:digest)

def look(box, name)
  box[name.to_s.downcase]
end

d = +"AB"
k = Key.new(d)
d << "!"
p k.digest

boxes = [{ "ab" => 1 }, Key]
p look(boxes[0], :AB)
p look(boxes[1], "CD")
p look(boxes[1], :EF).digest
