// Different: Nested loop vs flat loop
// Expected: no match at threshold 0.85

///|
fn matrix_traverse(matrix : Array[Array[Int]]) -> Int {
  let mut sum = 0
  for i = 0; i < matrix.length(); i = i + 1 {
    for j = 0; j < matrix[i].length(); j = j + 1 {
      sum = sum + matrix[i][j]
    }
  }
  sum
}

///|
fn array_sum(arr : Array[Int]) -> Int {
  let mut sum = 0
  for i = 0; i < arr.length(); i = i + 1 {
    sum = sum + arr[i]
  }
  sum
}
