// Similar: Different function definition styles with same body
// Expected: similarity >= 0.7

///|
fn sum_with_fn(arr : Array[Int]) -> Int {
  let mut total = 0
  for i = 0; i < arr.length(); i = i + 1 {
    total = total + arr[i]
  }
  total
}

///|
fn sum_with_different_name(items : Array[Int]) -> Int {
  let mut result = 0
  for j = 0; j < items.length(); j = j + 1 {
    result = result + items[j]
  }
  result
}
