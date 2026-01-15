///|
pub(all) struct TreeNode {
  mut label : String
  value : String
  mut children : Array[TreeNode]
  id : Int
  mut cached_size : Int // -1 means not cached
}

///|
pub fn TreeNode::new(label : String, value : String, id : Int) -> TreeNode {
  { label, value, children: [], id, cached_size: -1 }
}

///|
pub fn TreeNode::add_child(self : TreeNode, child : TreeNode) -> Unit {
  self.children.push(child)
  self.cached_size = -1 // Invalidate cache
}

///|
pub fn TreeNode::get_subtree_size(self : TreeNode) -> Int {
  if self.cached_size >= 0 {
    return self.cached_size
  }
  let mut size = 1
  for child in self.children {
    size = size + child.get_subtree_size()
  }
  self.cached_size = size
  size
}

///|
pub impl Show for TreeNode with output(self, logger) {
  logger.write_string("TreeNode(")
  logger.write_string(self.label)
  logger.write_string(", ")
  logger.write_string(self.value)
  logger.write_string(", children=")
  logger.write_string(self.children.length().to_string())
  logger.write_string(")")
}

///|
/// Add children count to labels for better structural comparison
/// e.g., "For" -> "For_3" if the node has 3 children
pub fn TreeNode::finalize_labels(self : TreeNode) -> Unit {
  let n = self.children.length()
  if n > 0 {
    self.label = "\{self.label}_\{n}"
    for child in self.children {
      child.finalize_labels()
    }
  }
}
