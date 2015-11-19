class JugglerSolver
  require 'matrix'
  # create instance variables to be used throughout the program
  def initialize
    @fname = "jugglefest.txt"
    @circuits = []
    @jugglers = []
    @queue = []
    @leftover = []
    @juggler_list = []
    @target
    @circuit_jugglers = {} 
    @c = {}
    @j = {}
    @file = File.open(@fname)
  end

  # read .txt file into program and populate necessary hashes and lists
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
    c.each_key { |key| @circuit_jugglers[key] = [] }

    # calculate target value in each circuit
    @target = @jugglers.count / @circuits.count
  end

  # add each juggler to @juggler_list as a hash containing their preferences and scores
  def build_jugglers_list(j, c)
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

  # assign jugglers to teams based on their current preference
  # if they have no more preferences then put them in the leftover
  # array
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

  # sort jugglers in descending score order. use preference
  # as a tie-breaker for even scores.
  def sort_jugglers(circuit_jugglers)
    circuit_jugglers.each do |course, jugglers|
      sorted_jugglers = jugglers.sort! { |x,y|
        # get x juggler's score
        jug_x_score = x[:scores][y[:current_pref]].values[0]
        # get y juggler's score
        jug_y_score = y[:scores][y[:current_pref]].values[0]

        # if the scores are equal, the juggler who's preference for this course
        # is higher wins
        if jug_y_score == jug_x_score 
          y[:current_pref] <=> x[:current_pref]
        else
          jug_y_score <=> jug_x_score
        end
      }
    end
  end

  # bump jugglers if they exceed the limit for the circuit team
  # add them back to the queue when bumped
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

  # compute the sum of juggler id #'s for a given circuit team
  def find_sum(circuit, circuit_jugglers)
    sum = 0
    circuit_jugglers[circuit].each do |juggler|
      sum += juggler[:id][1..-1].to_i
    end
    puts "The sum of #{circuit}'s juggler ID's is #{sum}"
  end

  # write the output to a text file with the proper formatting
  def write_output(circuit_jugglers)
    fname = "output.txt"
    file = File.open(fname, "w")

    circuit_jugglers.to_a.reverse.to_h.each do |key, course|
      jugglers = []
      0.upto(circuit_jugglers[key].size - 1) do |juggler|
        juggler_id = course[juggler][:id]
        juggler_scores = []
        course[juggler][:scores].each do |entry|
          course_no = entry.keys[0]
          score = entry.values[0]
          juggler_scores << "#{course_no}:#{score}"
        end
        jugglers << "#{juggler_id} #{juggler_scores.join(", ").gsub(",", "")}"
      end
      file.puts "#{key} #{jugglers.join(", ")}"
    end

    file.close
    puts "Wrote output to output.txt"
  end

  # solve the problem
  def solve
    puts "reading file and building lists..."
    read_file(@file, @circuits, @jugglers, @c, @j)
    build_jugglers_list(@j, @c)
    puts "solving problem..."
    while @queue.count > 0
      assign_jugglers(@queue, @leftover, @circuit_jugglers)
      sort_jugglers(@circuit_jugglers)
      bump_jugglers(@circuit_jugglers, @queue)
    end
    puts "done."
    write_output(@circuit_jugglers)
    find_sum("C1970", @circuit_jugglers) if @fname == "jugglefest.txt"
  end

end

jugglefest_solver = JugglerSolver.new
jugglefest_solver.solve
