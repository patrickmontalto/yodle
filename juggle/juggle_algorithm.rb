class JuggleSorter
end

require 'byebug'
require 'matrix'
file = File.open("juggle_small.txt")
file = File.open("jugglefest.txt")

circuits = []

jugglers = []

# queued jugglers to be assigned to their preference
queue = []

# leftover jugglers who will not be assigned to any of their preferences
@leftover = []

file.each do |line|
  line[0] == "C" ? circuits << line[2..-1].split : (jugglers << line[2..-1].split if line[0] == "J" )
end

@target = jugglers.count / circuits.count
c = {}
j = {}

# create circuits hash
circuits.each do |arr|
  c[arr[0]] = { arr[1][0] => arr[1][2..-1].to_i, arr[2][0] => arr[2][2..-1].to_i, arr[3][0] => arr[3][2..-1].to_i }
end

# create jugglers hash
jugglers.each do |arr|
  j[arr[0]] = { arr[1][0] => arr[1][2..-1].to_i, arr[2][0] => arr[2][2..-1].to_i, arr[3][0] => arr[3][2..-1].to_i, 
                :preferences => arr[4].split(",") }
end

@j = []

# add each juggler to @j as a hash {id: "J01", scores: [{C02: 112},{C01: 110},{C05: 93}], current_pref: 0}
j.each do |key, values|
  circuit_scores = []
  values[:preferences].each do |pref|
    j_scores = Vector.elements(j[key].values[0..2])
    circuit = Vector.elements(c[pref].values)
    circuit_scores << { pref => j_scores.inner_product(circuit)}
  end
  @j << { id: key, scores: circuit_scores, current_pref: 0 }
end


######
# create a hash of circuits with an array of jugglers
circuit_jugglers = {}
c.each_key { |key| circuit_jugglers[key] = [] }

# queue up all jugglers
queue = @j

# assign to preferences, sort, and then gather leftovers
while queue.count > 0
# insert into circuit_jugglers
  until (juggler = queue.shift) == nil
    unless juggler[:scores][juggler[:current_pref]] == nil
      circuit = juggler[:scores][juggler[:current_pref]].keys[0]
      circuit_jugglers[circuit] << juggler
    else
      @leftover << juggler
    end
  end

# sort circuit_jugglers
  circuit_jugglers.each do |course, jugglers|
    sorted_jugglers = jugglers.sort! { |x,y|
      jug_x_score = x[:scores][y[:current_pref]].values[0]
      jug_y_score = y[:scores][y[:current_pref]].values[0]

      if jug_y_score == jug_x_score 
        y[:current_pref] <=> x[:current_pref]
      else
        jug_y_score <=> jug_x_score
      end
    }
  end

# pop off the trailing extras and re-add to queue
  circuit_jugglers.each do |course, jugglers|
    if jugglers.count > @target
      overflow = jugglers.count - @target
      1.upto(overflow) do
        bumped = jugglers.pop
        bumped[:current_pref] += 1
        queue.push(bumped)
      end
    end
  end
  
end

sum = 0
circuit_jugglers["C1970"].each do |juggler|
  sum += juggler[:id][1..-1].to_i
end


## Write output 
fname = "output.txt"
file = File.open(fname, "w")

circuit_jugglers.each do |key, course|
  jugglers = []
  0.upto(circuit_jugglers[key].size - 1) do |juggler|
    juggler_id = course[juggler][:id]
    juggler_scores = []
    course[juggler][:scores].each do |entry|
      course_no = entry.keys[0]
      score = entry.values[0]
      juggler_scores << "#{course_no}:#{score}"
    end
    jugglers << "#{juggler_id} #{juggler_scores.join(", ")}"
  end
  file.puts "#{key} #{jugglers.join(", ")}"
end

file.close
puts "Wrote output to output.txt"
######

puts "The sum of C1970 juggler ID's is: #{sum}"




