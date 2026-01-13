// Similar: Copy-pasted code with minor constant changes
// Expected: similarity >= 0.7

///|
fn create_buffer1() -> Array[Int] {
  let buf : Array[Int] = Array::new(capacity=100)
  for i = 0; i < 100; i = i + 1 {
    buf.push(0)
  }
  buf
}

///|
fn create_buffer2() -> Array[Int] {
  let buf : Array[Int] = Array::new(capacity=200)
  for i = 0; i < 200; i = i + 1 {
    buf.push(0)
  }
  buf
}
