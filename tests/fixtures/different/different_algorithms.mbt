// Different: Completely different algorithms
// Expected: no match at threshold 0.85

///|
fn binary_search(arr : Array[Int], target : Int) -> Int {
  let mut left = 0
  let mut right = arr.length() - 1
  while left <= right {
    let mid = (left + right) / 2
    if arr[mid] == target {
      return mid
    } else if arr[mid] < target {
      left = mid + 1
    } else {
      right = mid - 1
    }
  }
  -1
}

///|
fn quicksort_partition(arr : Array[Int], low : Int, high : Int) -> Int {
  let pivot = arr[high]
  let mut i = low - 1
  for j = low; j < high; j = j + 1 {
    if arr[j] <= pivot {
      i = i + 1
      let temp = arr[i]
      arr[i] = arr[j]
      arr[j] = temp
    }
  }
  let temp = arr[i + 1]
  arr[i + 1] = arr[high]
  arr[high] = temp
  i + 1
}
