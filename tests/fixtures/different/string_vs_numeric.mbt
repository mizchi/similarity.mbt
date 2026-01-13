// Different: String processing vs numeric processing
// Expected: no match at threshold 0.85

///|
fn reverse_string(s : String) -> String {
  let chars = s.to_array()
  let mut left = 0
  let mut right = chars.length() - 1
  while left < right {
    let temp = chars[left]
    chars[left] = chars[right]
    chars[right] = temp
    left = left + 1
    right = right - 1
  }
  String::from_array(chars)
}

///|
fn is_prime(n : Int) -> Bool {
  if n <= 1 {
    return false
  }
  if n <= 3 {
    return true
  }
  if n % 2 == 0 || n % 3 == 0 {
    return false
  }
  let mut i = 5
  while i * i <= n {
    if n % i == 0 || n % (i + 2) == 0 {
      return false
    }
    i = i + 6
  }
  true
}
