require "../ponder"

require "random"

def random_start : Frob
  words = Frob.frobs.select { |f| f.type == :word }
  words.sample
end

def terminal?(f : Frob)
  f.type == :punct && (f.value == "." || f.value == "!" || f.value == "?")
end

def generate_sentence(max_steps = 50) : String
  current = random_start
  sentence = current.value.dup

  steps = 0
  while steps < max_steps
      break unless current.next_map.size > 0

    edges = current.next_map.values
    next_edge = weighted_sample(edges)
    current = next_edge.frob

    sentence += current.value
      break if terminal?(current)

    steps += 1
  end

  sentence
end

def weighted_sample(edges : Array(FrobEdge)) : FrobEdge
  total = edges.sum(&.forward_weight)
  roll = Random.rand(total)
  running = 0

  edges.each do |e|
    running += e.forward_weight
      return e if roll < running
  end

  edges.last
end

def main
  Frob.reset

  Dir.glob("./corpus/*.txt").each do |file|
      next unless File.file?(file)
    body = File.read(file, encoding: "UTF-8", invalid: :skip)
    Corp.new(file, body)
  end

  3.times do
    puts generate_sentence
  end
end



main()
