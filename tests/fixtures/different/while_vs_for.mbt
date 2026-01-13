// Different: While loop vs for loop (different semantics)
// Expected: no match at threshold 0.85

///|
fn find_zero_index(arr : Array[Int]) -> Int {
  let mut i = 0
  while i < arr.length() {
    if arr[i] == 0 {
      return i
    }
    i = i + 1
  }
  -1
}

///|
fn sum_until_zero(arr : Array[Int]) -> Int {
  let mut sum = 0
  for i = 0; i < arr.length(); i = i + 1 {
    if arr[i] == 0 {
      break
    }
    sum = sum + arr[i]
  }
  sum
}
