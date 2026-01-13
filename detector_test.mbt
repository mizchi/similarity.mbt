///|
test "extract_functions" {
  let source =
    #|///|
    #|fn add(a : Int, b : Int) -> Int {
    #|  a + b
    #|}
    #|
    #|///|
    #|fn multiply(x : Int, y : Int) -> Int {
    #|  x * y
    #|}
  let functions = extract_functions(source)
  inspect(functions.length(), content="2")
  inspect(functions[0].name, content="add")
  inspect(functions[1].name, content="multiply")
}

///|
test "detect_similar_functions" {
  let source =
    #|///|
    #|fn add1(a : Int, b : Int) -> Int {
    #|  a + b
    #|}
    #|
    #|///|
    #|fn add2(x : Int, y : Int) -> Int {
    #|  x + y
    #|}
    #|
    #|///|
    #|fn multiply(a : Int, b : Int) -> Int {
    #|  a * b
    #|}
  let options : @similarity.DetectorOptions = {
    threshold: 0.5,
    min_lines: 1,
    size_penalty: false,
  }
  let results = detect_similarities(source, options)
  inspect(results.length() > 0, content="true")
}

///|
test "identical_functions_have_high_similarity" {
  let source =
    #|///|
    #|fn func1(n : Int) -> Int {
    #|  if n <= 1 {
    #|    n
    #|  } else {
    #|    func1(n - 1) + func1(n - 2)
    #|  }
    #|}
    #|
    #|///|
    #|fn func2(n : Int) -> Int {
    #|  if n <= 1 {
    #|    n
    #|  } else {
    #|    func2(n - 1) + func2(n - 2)
    #|  }
    #|}
  let options : @similarity.DetectorOptions = {
    threshold: 0.5,
    min_lines: 1,
    size_penalty: false,
  }
  let results = detect_similarities(source, options)
  inspect(results.length() > 0, content="true")
  if results.length() > 0 {
    let first = results[0]
    inspect(first.similarity > 0.8, content="true")
  }
}

///|
test "different_structures_have_low_similarity" {
  let source =
    #|///|
    #|fn simple_add(a : Int, b : Int) -> Int {
    #|  a + b
    #|}
    #|
    #|///|
    #|fn complex_loop(n : Int) -> Int {
    #|  let mut sum = 0
    #|  for i = 0; i < n; i = i + 1 {
    #|    sum = sum + i
    #|  }
    #|  sum
    #|}
  let options : @similarity.DetectorOptions = {
    threshold: 0.95,
    min_lines: 1,
    size_penalty: false,
  }
  let results = detect_similarities(source, options)
  inspect(results.length() == 0, content="true")
}

///|
test "tree_node_subtree_size" {
  let root = TreeNode::new("Root", "", 0)
  let child1 = TreeNode::new("Child1", "", 1)
  let child2 = TreeNode::new("Child2", "", 2)
  let grandchild = TreeNode::new("Grandchild", "", 3)
  child1.add_child(grandchild)
  root.add_child(child1)
  root.add_child(child2)
  inspect(root.get_subtree_size(), content="4")
}

///|
test "tsed_identical_trees" {
  let tree1 = TreeNode::new("If", "", 0)
  let cond1 = TreeNode::new("Infix", "+", 1)
  let body1 = TreeNode::new("Constant", "Int", 2)
  tree1.add_child(cond1)
  tree1.add_child(body1)
  let tree2 = TreeNode::new("If", "", 3)
  let cond2 = TreeNode::new("Infix", "+", 4)
  let body2 = TreeNode::new("Constant", "Int", 5)
  tree2.add_child(cond2)
  tree2.add_child(body2)
  let options : @similarity.TSEDOptions = {
    apted_options: @similarity.APTEDOptions::default(),
    min_lines: 1,
    min_tokens: None,
    size_penalty: false,
  }
  let similarity = calculate_tsed(tree1, tree2, options)
  inspect(similarity > 0.5, content="true")
}
