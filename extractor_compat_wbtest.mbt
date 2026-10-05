///|
fn find_nodes(tree : TreeNode, label : String) -> Array[TreeNode] {
  let result = []
  if tree.label == label {
    result.push(tree)
  }
  for child in tree.children {
    result.append(find_nodes(child, label))
  }
  result
}

///|
fn extract_checked(source : String) -> Array[FunctionInfo] raise {
  let (_, reports) = @parser.parse_string(source)
  assert_eq(reports.length(), 0)
  extract_functions(source)
}

///|
test "modern parser preserves function method test and line locations" {
  let source =
    #|// 日本語 😀
    #|fn add(a : Int, b : Int) -> Int {
    #|  a + b
    #|}
    #|impl Show for Int with output(self, logger) {
    #|  logger.write_string("value")
    #|}
    #|test "addition" {
    #|  assert_eq(1 + 1, 2)
    #|}
  let functions = extract_checked(source)
  assert_eq(functions.length(), 3)
  assert_eq(functions[0].name, "add")
  assert_eq(functions[0].start_line, 2)
  assert_eq(functions[0].end_line, 4)
  assert_eq(functions[1].name, "output")
  assert_eq(functions[2].name, "test:addition")
  assert_eq(functions[2].end_line, 10)
  assert_eq(find_nodes(functions[0].tree, "Infix").length(), 1)
}

///|
test "interpolation source remains part of the similarity tree" {
  let source =
    #|fn format(a : Int) -> String {
    #|  "日本語 😀 \{if a > 0 { a + 1 } else { 0 }}"
    #|}
  let functions = extract_checked(source)
  assert_eq(functions.length(), 1)
  let tree = functions[0].tree
  assert_eq(find_nodes(tree, "Interp").length(), 1)
  assert_eq(find_nodes(tree, "If").length(), 1)
  let infix = find_nodes(tree, "Infix")
  assert_eq(infix.length(), 2)
  assert_eq(infix[0].value, ">")
  assert_eq(infix[1].value, "+")
}

///|
test "modern comprehensions keep iterator guard and body expressions" {
  let source =
    #|fn collect(xs : Array[Int]) -> Array[Int] {
    #|  [for x in xs if x > 0 => x + 1]
    #|}
  let functions = extract_checked(source)
  assert_eq(functions.length(), 1)
  let nodes = find_nodes(functions[0].tree, "ListComprehension")
  assert_eq(nodes.length(), 1)
  assert_eq(nodes[0].children.length(), 3)
  assert_eq(find_nodes(nodes[0], "Infix").length(), 2)
}
