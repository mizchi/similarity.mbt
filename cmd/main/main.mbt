///|
fn main {
  let source =
    #|///|
    #|fn min_double(a : Double, b : Double) -> Double {
    #|  if a < b { a } else { b }
    #|}
    #|
    #|///|
    #|fn max_double(a : Double, b : Double) -> Double {
    #|  if a > b { a } else { b }
    #|}
    #|
    #|///|
    #|fn min_int(x : Int, y : Int) -> Int {
    #|  if x < y { x } else { y }
    #|}
    #|
    #|///|
    #|fn max_int(x : Int, y : Int) -> Int {
    #|  if x > y { x } else { y }
    #|}
    #|
    #|///|
    #|fn add(a : Int, b : Int) -> Int {
    #|  a + b
    #|}
    #|
    #|///|
    #|fn compute_something(tree1 : TreeNode, tree2 : TreeNode) -> Double {
    #|  let memo : Map[String, Double] = {}
    #|  helper(tree1, tree2, memo)
    #|}
    #|
    #|///|
    #|fn calculate_other(node1 : TreeNode, node2 : TreeNode) -> Double {
    #|  let cache : Map[String, Double] = {}
    #|  do_calc(node1, node2, cache)
    #|}
  println("=== Similarity Detection ===")
  println("")
  let options : @lib.DetectorOptions = {
    threshold: 0.75,
    min_lines: 2,
    size_penalty: false,
  }
  let results = @lib.detect_similarities(source, options)
  if results.is_empty() {
    println("No similar functions found.")
  } else {
    for result in results {
      let pct = (result.similarity * 100.0).to_int()
      println("\{result.func1.name} <-> \{result.func2.name}: \{pct}%")
    }
  }
}
