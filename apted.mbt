///|
pub(all) struct APTEDOptions {
  rename_cost : Double
  delete_cost : Double
  insert_cost : Double
  compare_values : Bool
}

///|
pub fn APTEDOptions::default() -> APTEDOptions {
  {
    rename_cost: 1.0,
    delete_cost: 1.0,
    insert_cost: 1.0,
    compare_values: false,
  }
}

///|
pub fn compute_edit_distance(
  tree1 : TreeNode,
  tree2 : TreeNode,
  options : APTEDOptions,
) -> Double {
  let memo : Map[Int64, Double] = {}
  compute_edit_distance_recursive(tree1, tree2, options, memo)
}

///|
fn memo_key(id1 : Int, id2 : Int) -> Int64 {
  // Pack two 32-bit ints into one 64-bit int
  (id1.to_int64() << 32) | (id2.to_int64() & 0xFFFFFFFFL)
}

///|
fn compute_edit_distance_recursive(
  node1 : TreeNode,
  node2 : TreeNode,
  options : APTEDOptions,
  memo : Map[Int64, Double],
) -> Double {
  let key = memo_key(node1.id, node2.id)
  match memo.get(key) {
    Some(cost) => return cost
    None => ()
  }
  if node1.children.is_empty() && node2.children.is_empty() {
    let cost = if options.compare_values {
      if node1.label == node2.label && node1.value == node2.value {
        0.0
      } else {
        options.rename_cost
      }
    } else if node1.label == node2.label {
      0.0
    } else {
      options.rename_cost
    }
    memo.set(key, cost)
    return cost
  }
  let delete_all_cost = options.delete_cost *
    node1.get_subtree_size().to_double()
  let insert_all_cost = options.insert_cost *
    node2.get_subtree_size().to_double()
  let mut rename_plus_cost = if options.compare_values {
    if node1.label == node2.label && node1.value == node2.value {
      0.0
    } else {
      options.rename_cost
    }
  } else if node1.label == node2.label {
    // Penalize different number of children (structural difference)
    let children_diff = (node1.children.length() - node2.children.length()).abs()
    if children_diff > 0 {
      options.rename_cost * children_diff.to_double()
    } else {
      0.0
    }
  } else {
    options.rename_cost
  }
  if not(node1.children.is_empty()) || not(node2.children.is_empty()) {
    // Pre-compute child distances into memo
    for child1 in node1.children {
      for child2 in node2.children {
        ignore(compute_edit_distance_recursive(child1, child2, options, memo))
      }
    }
    let alignment_cost = compute_children_alignment(
      node1.children[:],
      node2.children[:],
      memo,
      options,
    )
    rename_plus_cost = rename_plus_cost + alignment_cost
  }
  let min_cost = @cmp.minimum(
    @cmp.minimum(delete_all_cost, insert_all_cost),
    rename_plus_cost,
  )
  memo.set(key, min_cost)
  min_cost
}

///|
fn compute_children_alignment(
  children1 : ArrayView[TreeNode],
  children2 : ArrayView[TreeNode],
  memo : Map[Int64, Double],
  options : APTEDOptions,
) -> Double {
  let m = children1.length()
  let n = children2.length()
  // Use 1D array optimization: only need current and previous row
  let mut prev : Array[Double] = Array::make(n + 1, 0.0)
  let mut curr : Array[Double] = Array::make(n + 1, 0.0)
  let insert_cost = options.insert_cost
  let delete_cost = options.delete_cost
  // Initialize first row
  for j = 1; j <= n; j = j + 1 {
    prev[j] = prev[j - 1] +
      insert_cost * children2[j - 1].get_subtree_size().to_double()
  }
  for i = 1; i <= m; i = i + 1 {
    let child1 = children1[i - 1]
    let child1_size = child1.get_subtree_size().to_double()
    curr[0] = prev[0] + delete_cost * child1_size
    for j = 1; j <= n; j = j + 1 {
      let child2 = children2[j - 1]
      let edit = memo.get(memo_key(child1.id, child2.id)).unwrap_or(0.0)
      let del = prev[j] + delete_cost * child1_size
      let ins = curr[j - 1] +
        insert_cost * child2.get_subtree_size().to_double()
      curr[j] = @cmp.minimum(@cmp.minimum(del, ins), prev[j - 1] + edit)
    }
    // Swap rows
    let tmp = prev
    prev = curr
    curr = tmp
  }
  prev[n]
}
