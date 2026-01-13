// Similar: Nested loop patterns
// Expected: similarity >= 0.7

///|
fn matrix_sum(matrix : Array[Array[Int]]) -> Int {
  let mut total = 0
  for i = 0; i < matrix.length(); i = i + 1 {
    for j = 0; j < matrix[i].length(); j = j + 1 {
      total = total + matrix[i][j]
    }
  }
  total
}

///|
fn matrix_product(grid : Array[Array[Int]]) -> Int {
  let mut result = 1
  for row = 0; row < grid.length(); row = row + 1 {
    for col = 0; col < grid[row].length(); col = col + 1 {
      result = result * grid[row][col]
    }
  }
  result
}
