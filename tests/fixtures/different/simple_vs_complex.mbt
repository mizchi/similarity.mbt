// Different: Simple vs complex function
// Expected: no match at threshold 0.85

///|
fn simple_add(a : Int, b : Int) -> Int {
  let result = a + b
  result
}

///|
fn merge_sort(arr : Array[Int]) -> Array[Int] {
  if arr.length() <= 1 {
    return arr
  }
  let mid = arr.length() / 2
  let left : Array[Int] = []
  let right : Array[Int] = []
  for i = 0; i < mid; i = i + 1 {
    left.push(arr[i])
  }
  for i = mid; i < arr.length(); i = i + 1 {
    right.push(arr[i])
  }
  let sorted_left = merge_sort(left)
  let sorted_right = merge_sort(right)
  merge(sorted_left, sorted_right)
}
