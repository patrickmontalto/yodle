puts "Please enter file name from below: "
puts Dir.entries(".").select { |x| x.include?(".txt") }
fname = gets.chomp

# Open file and set it as 2D array. Convert each string to an integer.
file = File.open(fname)
triangle = []
file.each do |line|
  triangle << line.split.map! { |n| n.to_i }
end

# This method finds the max adjacent number of the previous row to the 
# current position.
def max_adjacent(row, index, triangle)
  adjacent = []
  adjacent << triangle[row-1][index] unless triangle[row-1][index].nil?
  adjacent << triangle[row-1][index - 1] unless triangle[row-1][index - 1].nil?
  adjacent.max
end

# The algorithm operates by comparing the two adjacent numbers 
# in the row above of a given number. The higher of the two
# numbers is that number. This continues until the last row,
# where the maximum sum is the maximum integer within that
# row. 

@tri_sum = [[triangle[0][0]]]
answer = 0

1.upto(triangle.size - 1) do |i|
  @tri_sum << triangle[i].each_with_index.map do |num, index|
    num + max_adjacent(i,index, @tri_sum)
  end
  answer = @tri_sum[i].max
end

puts "The answer for #{fname} is #{answer}"