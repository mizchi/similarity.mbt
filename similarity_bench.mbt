///|
/// Sample code for benchmarking
let sample_source : String =
  #|///|
  #|fn fibonacci(n : Int) -> Int {
  #|  if n <= 1 {
  #|    n
  #|  } else {
  #|    fibonacci(n - 1) + fibonacci(n - 2)
  #|  }
  #|}
  #|
  #|///|
  #|fn factorial(n : Int) -> Int {
  #|  if n <= 1 {
  #|    1
  #|  } else {
  #|    n * factorial(n - 1)
  #|  }
  #|}
  #|
  #|///|
  #|fn sum_array(arr : Array[Int]) -> Int {
  #|  let mut sum = 0
  #|  for i = 0; i < arr.length(); i = i + 1 {
  #|    sum = sum + arr[i]
  #|  }
  #|  sum
  #|}
  #|
  #|///|
  #|fn complex_loop(n : Int) -> Int {
  #|  let mut result = 0
  #|  for i = 0; i < n; i = i + 1 {
  #|    for j = 0; j < n; j = j + 1 {
  #|      result = result + i * j
  #|    }
  #|  }
  #|  result
  #|}
  #|
  #|///|
  #|fn fibonacci2(n : Int) -> Int {
  #|  if n <= 1 {
  #|    n
  #|  } else {
  #|    fibonacci2(n - 1) + fibonacci2(n - 2)
  #|  }
  #|}
  #|
  #|///|
  #|fn process_array(arr : Array[Int]) -> Int {
  #|  let mut total = 0
  #|  for i = 0; i < arr.length(); i = i + 1 {
  #|    total = total + arr[i]
  #|  }
  #|  total
  #|}

///|
test "bench extract_functions" (b : @bench.T) {
  b.bench(fn() { b.keep(extract_functions(sample_source)) })
}

///|
test "bench detect_similarities" (b : @bench.T) {
  let options : DetectorOptions = {
    threshold: 0.8,
    min_lines: 3,
    size_penalty: true,
  }
  b.bench(fn() { b.keep(detect_similarities(sample_source, options)) })
}

///|
test "bench compute_edit_distance" (b : @bench.T) {
  let functions = extract_functions(sample_source)
  guard functions.length() >= 2
  let tree1 = functions[0].tree
  let tree2 = functions[1].tree
  let options = APTEDOptions::default()
  b.bench(fn() { b.keep(compute_edit_distance(tree1, tree2, options)) })
}

///|
test "bench calculate_tsed" (b : @bench.T) {
  let functions = extract_functions(sample_source)
  guard functions.length() >= 2
  let tree1 = functions[0].tree
  let tree2 = functions[1].tree
  let options : TSEDOptions = {
    apted_options: APTEDOptions::default(),
    min_lines: 3,
    min_tokens: None,
    size_penalty: true,
  }
  b.bench(fn() { b.keep(calculate_tsed(tree1, tree2, options)) })
}

///|
test "bench get_subtree_size" (b : @bench.T) {
  let functions = extract_functions(sample_source)
  guard functions.length() >= 1
  let tree = functions[0].tree
  b.bench(fn() { b.keep(tree.get_subtree_size()) })
}

///|
/// Larger source for stress testing
let large_sample_source : String =
  #|///|
  #|fn func1(n : Int) -> Int {
  #|  if n <= 1 { n } else { func1(n - 1) + func1(n - 2) }
  #|}
  #|///|
  #|fn func2(n : Int) -> Int {
  #|  if n <= 1 { n } else { func2(n - 1) + func2(n - 2) }
  #|}
  #|///|
  #|fn func3(n : Int) -> Int {
  #|  if n <= 1 { 1 } else { n * func3(n - 1) }
  #|}
  #|///|
  #|fn func4(n : Int) -> Int {
  #|  if n <= 1 { 1 } else { n * func4(n - 1) }
  #|}
  #|///|
  #|fn func5(arr : Array[Int]) -> Int {
  #|  let mut sum = 0
  #|  for i = 0; i < arr.length(); i = i + 1 { sum = sum + arr[i] }
  #|  sum
  #|}
  #|///|
  #|fn func6(arr : Array[Int]) -> Int {
  #|  let mut sum = 0
  #|  for i = 0; i < arr.length(); i = i + 1 { sum = sum + arr[i] }
  #|  sum
  #|}
  #|///|
  #|fn func7(n : Int) -> Int {
  #|  let mut result = 0
  #|  for i = 0; i < n; i = i + 1 {
  #|    for j = 0; j < n; j = j + 1 { result = result + i * j }
  #|  }
  #|  result
  #|}
  #|///|
  #|fn func8(n : Int) -> Int {
  #|  let mut result = 0
  #|  for i = 0; i < n; i = i + 1 {
  #|    for j = 0; j < n; j = j + 1 { result = result + i * j }
  #|  }
  #|  result
  #|}
  #|///|
  #|fn func9(x : Int, y : Int) -> Int {
  #|  if x > y { x - y } else { y - x }
  #|}
  #|///|
  #|fn func10(a : Int, b : Int) -> Int {
  #|  if a > b { a - b } else { b - a }
  #|}
  #|///|
  #|fn func11(items : Array[Int]) -> Array[Int] {
  #|  let result : Array[Int] = []
  #|  for item in items { if item > 0 { result.push(item) } }
  #|  result
  #|}
  #|///|
  #|fn func12(items : Array[Int]) -> Array[Int] {
  #|  let result : Array[Int] = []
  #|  for item in items { if item > 0 { result.push(item) } }
  #|  result
  #|}

///|
test "bench detect_similarities_large" (b : @bench.T) {
  let options : DetectorOptions = {
    threshold: 0.8,
    min_lines: 3,
    size_penalty: true,
  }
  b.bench(fn() { b.keep(detect_similarities(large_sample_source, options)) })
}

///|
test "bench memo_key_string_creation" (b : @bench.T) {
  // Test string key creation overhead
  b.bench(fn() {
    let mut result = 0
    for i = 0; i < 100; i = i + 1 {
      for j = 0; j < 100; j = j + 1 {
        let key = "\{i},\{j}"
        result = result + key.length()
      }
    }
    b.keep(result)
  })
}
