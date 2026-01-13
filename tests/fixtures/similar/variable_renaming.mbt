// Similar: Variable renaming should be detected
// Expected: similarity >= 0.8

///|
fn sum_array1(arr : Array[Int]) -> Int {
  let mut total = 0
  for i = 0; i < arr.length(); i = i + 1 {
    total = total + arr[i]
  }
  total
}

///|
fn sum_array2(items : Array[Int]) -> Int {
  let mut result = 0
  for j = 0; j < items.length(); j = j + 1 {
    result = result + items[j]
  }
  result
}
