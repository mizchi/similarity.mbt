// Different: Early return pattern vs accumulate pattern
// Expected: no match at threshold 0.85

///|
fn find_first_negative(arr : Array[Int]) -> Int? {
  for i = 0; i < arr.length(); i = i + 1 {
    if arr[i] < 0 {
      return Some(arr[i])
    }
  }
  None
}

///|
fn count_negatives(arr : Array[Int]) -> Int {
  let mut count = 0
  for i = 0; i < arr.length(); i = i + 1 {
    if arr[i] < 0 {
      count = count + 1
    }
  }
  count
}
