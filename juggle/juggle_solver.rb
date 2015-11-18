require 'byebug'
file = File.open("juggle_small.txt")
file = File.open("jugglefest.txt")
circuits = []

jugglers = []

file.each do |line|
  line[0] == "C" ? circuits << line[2..-1].split : (jugglers << line[2..-1].split if line[0] == "J" )
end

c = {}
j = {}

circuits.each do |arr|
  c[arr[0]] = { arr[1][0] => arr[1][2..-1].to_i, arr[2][0] => arr[2][2..-1].to_i, arr[3][0] => arr[3][2..-1].to_i }
end

jugglers.each do |arr|
  j[arr[0]] = { arr[1][0] => arr[1][2..-1].to_i, arr[2][0] => arr[2][2..-1].to_i, arr[3][0] => arr[3][2..-1].to_i, 
                :preference => arr[4].split(",") }
end

@target = jugglers.count / circuits.count

#################
### NEW IDEA  ###
#################

circuit_scores = {}
c.each_key { |key| circuit_scores[key] = {} }

# build a hash of courses, with hash containing the scores 
# of each juggler for that circuit
j.each_key do |juggler|
  0.upto(j["J0"][:preference].size - 1) do |pref|
    circuit = j[juggler][:preference][pref]
    circuit_scores[circuit][juggler] = ( c[circuit]["H"] * j[juggler]["H"] ) +
                                       ( c[circuit]["E"] * j[juggler]["E"] ) +
                                       ( c[circuit]["P"] * j[juggler]["P"] )   
  end
end


######
circuit_jugglers = {}
c.each_key { |key| circuit_jugglers[key] = [] }
juggler_list = j.keys
#juggler_list.each do |juggler|
#  0.upto(2) do |pref|
#    [j[juggler][:preference][pref]] 
#  end
#end

circuits_list = []
c.each_key { |key| circuits_list << key }
# returns the number of circuits filled
def circuits_filled?(circuit_jugglers, circuits_list)
  filled = 0
  circuits_list.each do |circuit|
    filled += 1 if circuit_jugglers[circuit].size == @target
  end
  filled
end

# continue until target has been hit for each circuit. Start at first choice (i = 0)

checked = {}
circuit_no = 0
j.each_key { |key| checked[key] = [-1] }


until circuits_filled?(circuit_jugglers, circuits_list) == circuits.size
  juggler_list.each do |juggler|
    unless circuit_jugglers.flatten.flatten.include?(juggler)
      pos = checked[juggler].last + 1
      checked[juggler] << pos
      circuit_no = j[juggler][:preference][pos]
      circuit_jugglers[circuit_no] << [juggler, circuit_scores[circuit_no][juggler]] # add juggler to their next pick
      circuit_jugglers[circuit_no].sort_by! { |x, y| y }.reverse! # order circuit_jugglers for circuit in descending score order
      if circuit_jugglers[circuit_no].count > 4 
        lowest_juggler = circuit_jugglers[circuit_no].pop
        puts "lowest juggler was #{lowest_juggler} was bumped from #{circuit_no}"
      end
    end
  end
end



