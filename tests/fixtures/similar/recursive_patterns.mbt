// Similar: Recursive patterns
// Expected: similarity >= 0.6

///|
fn factorial(n : Int) -> Int {
  if n <= 1 {
    1
  } else {
    n * factorial(n - 1)
  }
}

///|
fn sum_to_n(n : Int) -> Int {
  if n <= 0 {
    0
  } else {
    n + sum_to_n(n - 1)
  }
}
