class JugglerSolver
  require 'matrix'
  def initialize
    @circuits = []
    @jugglers = []
    @queue = []
    @leftover = []
    @juggler_list = []
    @target
    @circuit_jugglers = {} 
    @c = {}
    @j = {}
    @file = File.open("jugglefest.txt")
  end

  def read_file(file, circuits, jugglers, c, j)
    # read each line so that it can be made into a hash of circuits and jugglers
    file.each do |line|
      line[0] == "C" ? circuits << line[2..-1].split : (jugglers << line[2..-1].split if line[0] == "J" )
    end
    # create circuits hash
    circuits.each do |arr|
      c[arr[0]] = { arr[1][0] => arr[1][2..-1].to_i, arr[2][0] => arr[2][2..-1].to_i, arr[3][0] => arr[3][2..-1].to_i }
    end
    # create jugglers hash
    jugglers.each do |arr|
      j[arr[0]] = { arr[1][0] => arr[1][2..-1].to_i, arr[2][0] => arr[2][2..-1].to_i, arr[3][0] => arr[3][2..-1].to_i, 
                    :preferences => arr[4].split(",") }
    end

    # create a hash of circuits with an array of jugglers. this will be used to store the results.
    circuit_jugglers = {}
    c.each_key { |key| circuit_jugglers[key] = [] }

    # calculate target value in each circuit
    @target = @jugglers.count / @circuits.count
  end

  def build_jugglers_list(j, c)
    # add each juggler to @juggler_list as a hash {id: "J01", scores: [{C02: 112},{C01: 110},{C05: 93}], current_pref: 0}
    j.each do |key, values|
      circuit_scores = []
      values[:preferences].each do |pref|
        j_scores = Vector.elements(j[key].values[0..2])
        circuit = Vector.elements(c[pref].values)
        circuit_scores << { pref => j_scores.inner_product(circuit)}
      end
      @juggler_list << { id: key, scores: circuit_scores, current_pref: 0 }
    end
    # queue up all jugglers
    @queue = @juggler_list
  end

  def assign_jugglers(queue, leftover, circuit_jugglers)
    until (juggler = queue.shift) == nil
      unless juggler[:scores][juggler[:current_pref]] == nil
        circuit = juggler[:scores][juggler[:current_pref]].keys[0]
        circuit_jugglers[circuit] << juggler
      else
        leftover << juggler
      end
    end
  end

  def sort_jugglers(circuit_jugglers)
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
  end

  def bump_jugglers(circuit_jugglers, queue)
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

  def find_sum(circuit, circuit_jugglers)
    sum = 0
    circuit_jugglers[circuit].each do |juggler|
      sum += juggler[:id][1..-1].to_i
    end
    puts "The sum of #{circuit}'s juggler ID's is #{sum}"
  end

  def write_output(circuit_jugglers)
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
  end

  def solve
    read_file(@file, @circuits, @jugglers, @c, @j)
    build_jugglers_list(@j, @c)
    while @queue.count > 0
      assign_jugglers(@queue, @leftover, @circuit_jugglers)
      sort_jugglers(@circuit_jugglers)
      bump_jugglers(@circuit_jugglers, @queue)
      find_sum("C1970", @circuit_jugglers)
      write_output(@circuit_jugglers)
    end
  end

end

jugglefest_solver = JugglerSolver.new
jugglefest_solver.solve
