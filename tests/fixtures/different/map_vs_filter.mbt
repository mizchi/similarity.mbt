// Different: Map operation vs filter operation
// Expected: no match at threshold 0.85

///|
fn double_all(arr : Array[Int]) -> Array[Int] {
  let result : Array[Int] = []
  for i = 0; i < arr.length(); i = i + 1 {
    result.push(arr[i] * 2)
  }
  result
}

///|
fn filter_positive(arr : Array[Int]) -> Array[Int] {
  let result : Array[Int] = []
  for i = 0; i < arr.length(); i = i + 1 {
    if arr[i] > 0 {
      result.push(arr[i])
    }
  }
  result
}
