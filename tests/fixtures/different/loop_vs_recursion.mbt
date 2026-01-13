// Different: Loop vs recursion
// Expected: no match at threshold 0.85

///|
fn sum_iterative(n : Int) -> Int {
  let mut total = 0
  for i = 1; i <= n; i = i + 1 {
    total = total + i
  }
  total
}

///|
fn fibonacci(n : Int) -> Int {
  if n <= 1 {
    n
  } else {
    fibonacci(n - 1) + fibonacci(n - 2)
  }
}
