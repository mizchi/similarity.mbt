// Similar: Loop patterns with different operations
// Expected: similarity >= 0.8

///|
fn find_max(arr : Array[Int]) -> Int {
  let mut max = arr[0]
  for i = 1; i < arr.length(); i = i + 1 {
    if arr[i] > max {
      max = arr[i]
    }
  }
  max
}

///|
fn find_min(arr : Array[Int]) -> Int {
  let mut min = arr[0]
  for i = 1; i < arr.length(); i = i + 1 {
    if arr[i] < min {
      min = arr[i]
    }
  }
  min
}
