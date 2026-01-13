///|
pub(all) struct FunctionInfo {
  name : String
  start_line : Int
  end_line : Int
  tree : TreeNode
}

///|
pub impl Show for FunctionInfo with output(self, logger) {
  logger.write_string("FunctionInfo(")
  logger.write_string(self.name)
  logger.write_string(", lines=")
  logger.write_string(self.start_line.to_string())
  logger.write_string("-")
  logger.write_string(self.end_line.to_string())
  logger.write_string(")")
}

///|
priv struct IdGenerator {
  mut next_id : Int
}

///|
fn IdGenerator::new() -> IdGenerator {
  { next_id: 0 }
}

///|
fn IdGenerator::next(self : IdGenerator) -> Int {
  let id = self.next_id
  self.next_id = self.next_id + 1
  id
}

///|
pub fn extract_functions(source : String) -> Array[FunctionInfo] {
  let (impls, _) = @parser.parse_string(source)
  let functions : Array[FunctionInfo] = []
  let id_gen = IdGenerator::new()
  for impl_ in impls {
    match impl_ {
      TopFuncDef(fun_decl~, decl_body~, loc~) => {
        let name = fun_decl.name.name
        let tree = decl_body_to_tree(decl_body, id_gen)
        functions.push({
          name,
          start_line: loc.start.lnum,
          end_line: loc.end.lnum,
          tree,
        })
      }
      TopImpl(method_name~, body~, loc~, ..) => {
        let name = method_name.name
        let tree = decl_body_to_tree(body, id_gen)
        functions.push({
          name,
          start_line: loc.start.lnum,
          end_line: loc.end.lnum,
          tree,
        })
      }
      TopTest(expr~, name~, loc~, ..) => {
        let test_name = match name {
          Some((s, _)) => "test:\{s}"
          None => "test"
        }
        let tree = expr_to_tree(expr, id_gen)
        functions.push({
          name: test_name,
          start_line: loc.start.lnum,
          end_line: loc.end.lnum,
          tree,
        })
      }
      _ => ()
    }
  }
  functions
}

///|
fn decl_body_to_tree(body : @syntax.DeclBody, id_gen : IdGenerator) -> TreeNode {
  match body {
    DeclBody(expr~, ..) => expr_to_tree(expr, id_gen)
    DeclStubs(stubs) =>
      match stubs {
        Import(module_name~, func_name~, ..) => {
          let node = TreeNode::new(
            "Import",
            "\{module_name}:\{func_name}",
            id_gen.next(),
          )
          node
        }
        Embedded(..) => TreeNode::new("Embedded", "", id_gen.next())
      }
  }
}

///|
fn expr_to_tree(expr : @syntax.Expr, id_gen : IdGenerator) -> TreeNode {
  match expr {
    Apply(func~, args~, ..) => {
      let node = TreeNode::new("Apply", "", id_gen.next())
      node.add_child(expr_to_tree(func, id_gen))
      for arg in args {
        node.add_child(expr_to_tree(arg.value, id_gen))
      }
      node
    }
    Infix(op~, lhs~, rhs~, ..) => {
      let op_name = match op.name {
        Ident(name~) => name
        Dot(pkg~, id~) => "\{pkg}.\{id}"
      }
      let node = TreeNode::new("Infix", op_name, id_gen.next())
      node.add_child(expr_to_tree(lhs, id_gen))
      node.add_child(expr_to_tree(rhs, id_gen))
      node
    }
    Unary(op~, expr~, ..) => {
      let op_name = match op.name {
        Ident(name~) => name
        Dot(pkg~, id~) => "\{pkg}.\{id}"
      }
      let node = TreeNode::new("Unary", op_name, id_gen.next())
      node.add_child(expr_to_tree(expr, id_gen))
      node
    }
    Array(exprs~, ..) => {
      let node = TreeNode::new("Array", "", id_gen.next())
      for e in exprs {
        node.add_child(expr_to_tree(e, id_gen))
      }
      node
    }
    ArraySpread(elems~, ..) => {
      let node = TreeNode::new("ArraySpread", "", id_gen.next())
      for elem in elems {
        match elem {
          Regular(e) => node.add_child(expr_to_tree(e, id_gen))
          Spread(expr~, ..) => {
            let spread_node = TreeNode::new("Spread", "", id_gen.next())
            spread_node.add_child(expr_to_tree(expr, id_gen))
            node.add_child(spread_node)
          }
        }
      }
      node
    }
    ArrayGet(array~, index~, ..) => {
      let node = TreeNode::new("ArrayGet", "", id_gen.next())
      node.add_child(expr_to_tree(array, id_gen))
      node.add_child(expr_to_tree(index, id_gen))
      node
    }
    ArrayGetSlice(array~, start_index~, end_index~, ..) => {
      let node = TreeNode::new("ArrayGetSlice", "", id_gen.next())
      node.add_child(expr_to_tree(array, id_gen))
      match start_index {
        Some(e) => node.add_child(expr_to_tree(e, id_gen))
        None => ()
      }
      match end_index {
        Some(e) => node.add_child(expr_to_tree(e, id_gen))
        None => ()
      }
      node
    }
    ArraySet(array~, index~, value~, ..) => {
      let node = TreeNode::new("ArraySet", "", id_gen.next())
      node.add_child(expr_to_tree(array, id_gen))
      node.add_child(expr_to_tree(index, id_gen))
      node.add_child(expr_to_tree(value, id_gen))
      node
    }
    ArrayAugmentedSet(op~, array~, index~, value~, ..) => {
      let op_name = match op.name {
        Ident(name~) => name
        Dot(pkg~, id~) => "\{pkg}.\{id}"
      }
      let node = TreeNode::new("ArrayAugmentedSet", op_name, id_gen.next())
      node.add_child(expr_to_tree(array, id_gen))
      node.add_child(expr_to_tree(index, id_gen))
      node.add_child(expr_to_tree(value, id_gen))
      node
    }
    Constant(c~, ..) => {
      let label = match c {
        Bool(_) => "Bool"
        Byte(_) => "Byte"
        Bytes(_) => "Bytes"
        Char(_) => "Char"
        Int(_) => "Int"
        Int64(_) => "Int64"
        UInt(_) => "UInt"
        UInt64(_) => "UInt64"
        Float(_) => "Float"
        Double(_) => "Double"
        String(_) => "String"
        BigInt(_) => "BigInt"
      }
      TreeNode::new("Constant", label, id_gen.next())
    }
    MultilineString(..) => TreeNode::new("MultilineString", "", id_gen.next())
    Interp(elems~, ..) => {
      let node = TreeNode::new("Interp", "", id_gen.next())
      for elem in elems {
        match elem {
          Expr(expr~, ..) => node.add_child(expr_to_tree(expr, id_gen))
          _ => ()
        }
      }
      node
    }
    Constraint(expr~, ..) => {
      let node = TreeNode::new("Constraint", "", id_gen.next())
      node.add_child(expr_to_tree(expr, id_gen))
      node
    }
    Constr(constr~, ..) =>
      TreeNode::new("Constr", constr.name.name, id_gen.next())
    While(loop_cond~, loop_body~, while_else~, ..) => {
      let node = TreeNode::new("While", "", id_gen.next())
      node.add_child(expr_to_tree(loop_cond, id_gen))
      node.add_child(expr_to_tree(loop_body, id_gen))
      match while_else {
        Some(e) => node.add_child(expr_to_tree(e, id_gen))
        None => ()
      }
      node
    }
    Function(func~, ..) => {
      let node = TreeNode::new("Function", "", id_gen.next())
      node.add_child(expr_to_tree(func.body, id_gen))
      node
    }
    Ident(id~, ..) => {
      let name = match id.name {
        Ident(name~) => name
        Dot(pkg~, id~) => "\{pkg}.\{id}"
      }
      TreeNode::new("Ident", name, id_gen.next())
    }
    If(cond~, ifso~, ifnot~, ..) => {
      let node = TreeNode::new("If", "", id_gen.next())
      node.add_child(expr_to_tree(cond, id_gen))
      node.add_child(expr_to_tree(ifso, id_gen))
      match ifnot {
        Some(e) => node.add_child(expr_to_tree(e, id_gen))
        None => ()
      }
      node
    }
    Guard(cond~, otherwise~, body~, ..) => {
      let node = TreeNode::new("Guard", "", id_gen.next())
      node.add_child(expr_to_tree(cond, id_gen))
      match otherwise {
        Some(e) => node.add_child(expr_to_tree(e, id_gen))
        None => ()
      }
      node.add_child(expr_to_tree(body, id_gen))
      node
    }
    Is(expr~, ..) => {
      let node = TreeNode::new("Is", "", id_gen.next())
      node.add_child(expr_to_tree(expr, id_gen))
      node
    }
    IsLexMatch(expr~, ..) => {
      let node = TreeNode::new("IsLexMatch", "", id_gen.next())
      node.add_child(expr_to_tree(expr, id_gen))
      node
    }
    Defer(expr~, body~, ..) => {
      let node = TreeNode::new("Defer", "", id_gen.next())
      node.add_child(expr_to_tree(expr, id_gen))
      node.add_child(expr_to_tree(body, id_gen))
      node
    }
    LetFn(func~, body~, ..) => {
      let node = TreeNode::new("LetFn", "", id_gen.next())
      node.add_child(expr_to_tree(func.body, id_gen))
      node.add_child(expr_to_tree(body, id_gen))
      node
    }
    LetRec(bindings~, body~, ..) => {
      let node = TreeNode::new("LetRec", "", id_gen.next())
      for binding in bindings {
        let (_, func) = binding
        node.add_child(expr_to_tree(func.body, id_gen))
      }
      node.add_child(expr_to_tree(body, id_gen))
      node
    }
    LetAnd(bindings~, body~, ..) => {
      let node = TreeNode::new("LetAnd", "", id_gen.next())
      for binding in bindings {
        let (_, _, func) = binding
        node.add_child(expr_to_tree(func.body, id_gen))
      }
      node.add_child(expr_to_tree(body, id_gen))
      node
    }
    Let(expr~, body~, ..) => {
      let node = TreeNode::new("Let", "", id_gen.next())
      node.add_child(expr_to_tree(expr, id_gen))
      node.add_child(expr_to_tree(body, id_gen))
      node
    }
    Sequence(exprs~, last_expr~, ..) => {
      let node = TreeNode::new("Sequence", "", id_gen.next())
      for e in exprs {
        node.add_child(expr_to_tree(e, id_gen))
      }
      node.add_child(expr_to_tree(last_expr, id_gen))
      node
    }
    Tuple(exprs~, ..) => {
      let node = TreeNode::new("Tuple", "", id_gen.next())
      for e in exprs {
        node.add_child(expr_to_tree(e, id_gen))
      }
      node
    }
    Record(fields~, ..) => {
      let node = TreeNode::new("Record", "", id_gen.next())
      for field in fields {
        node.add_child(expr_to_tree(field.expr, id_gen))
      }
      node
    }
    RecordUpdate(record~, fields~, ..) => {
      let node = TreeNode::new("RecordUpdate", "", id_gen.next())
      node.add_child(expr_to_tree(record, id_gen))
      for field in fields {
        node.add_child(expr_to_tree(field.expr, id_gen))
      }
      node
    }
    Field(record~, ..) => {
      let node = TreeNode::new("Field", "", id_gen.next())
      node.add_child(expr_to_tree(record, id_gen))
      node
    }
    Method(..) => TreeNode::new("Method", "", id_gen.next())
    DotApply(self~, args~, ..) => {
      let node = TreeNode::new("DotApply", "", id_gen.next())
      node.add_child(expr_to_tree(self, id_gen))
      for arg in args {
        node.add_child(expr_to_tree(arg.value, id_gen))
      }
      node
    }
    As(expr~, ..) => {
      let node = TreeNode::new("As", "", id_gen.next())
      node.add_child(expr_to_tree(expr, id_gen))
      node
    }
    Mutate(record~, field~, ..) => {
      let node = TreeNode::new("Mutate", "", id_gen.next())
      node.add_child(expr_to_tree(record, id_gen))
      node.add_child(expr_to_tree(field, id_gen))
      node
    }
    Match(expr~, cases~, ..) => {
      let node = TreeNode::new("Match", "", id_gen.next())
      node.add_child(expr_to_tree(expr, id_gen))
      for case in cases {
        node.add_child(expr_to_tree(case.body, id_gen))
      }
      node
    }
    LexMatch(expr~, cases~, ..) => {
      let node = TreeNode::new("LexMatch", "", id_gen.next())
      node.add_child(expr_to_tree(expr, id_gen))
      for case in cases {
        node.add_child(expr_to_tree(case.body, id_gen))
      }
      node
    }
    LetMut(expr~, body~, ..) => {
      let node = TreeNode::new("LetMut", "", id_gen.next())
      node.add_child(expr_to_tree(expr, id_gen))
      node.add_child(expr_to_tree(body, id_gen))
      node
    }
    Pipe(lhs~, rhs~, ..) => {
      let node = TreeNode::new("Pipe", "", id_gen.next())
      node.add_child(expr_to_tree(lhs, id_gen))
      node.add_child(expr_to_tree(rhs, id_gen))
      node
    }
    Assign(expr~, ..) => {
      let node = TreeNode::new("Assign", "", id_gen.next())
      node.add_child(expr_to_tree(expr, id_gen))
      node
    }
    Hole(..) => TreeNode::new("Hole", "", id_gen.next())
    Return(return_value~, ..) => {
      let node = TreeNode::new("Return", "", id_gen.next())
      match return_value {
        Some(e) => node.add_child(expr_to_tree(e, id_gen))
        None => ()
      }
      node
    }
    Raise(err_value~, ..) => {
      let node = TreeNode::new("Raise", "", id_gen.next())
      node.add_child(expr_to_tree(err_value, id_gen))
      node
    }
    Unit(..) => TreeNode::new("Unit", "", id_gen.next())
    Break(arg~, ..) => {
      let node = TreeNode::new("Break", "", id_gen.next())
      match arg {
        Some(e) => node.add_child(expr_to_tree(e, id_gen))
        None => ()
      }
      node
    }
    Continue(args~, ..) => {
      let node = TreeNode::new("Continue", "", id_gen.next())
      for e in args {
        node.add_child(expr_to_tree(e, id_gen))
      }
      node
    }
    Loop(arg~, body~, ..) => {
      let node = TreeNode::new("Loop", "", id_gen.next())
      node.add_child(expr_to_tree(arg, id_gen))
      for case in body {
        node.add_child(expr_to_tree(case.body, id_gen))
      }
      node
    }
    For(binders~, condition~, continue_block~, body~, for_else~, ..) => {
      let node = TreeNode::new("For", "", id_gen.next())
      for binder in binders {
        let (_, e) = binder
        node.add_child(expr_to_tree(e, id_gen))
      }
      match condition {
        Some(e) => node.add_child(expr_to_tree(e, id_gen))
        None => ()
      }
      for cont in continue_block {
        let (_, e) = cont
        node.add_child(expr_to_tree(e, id_gen))
      }
      node.add_child(expr_to_tree(body, id_gen))
      match for_else {
        Some(e) => node.add_child(expr_to_tree(e, id_gen))
        None => ()
      }
      node
    }
    ForEach(expr~, body~, else_block~, ..) => {
      let node = TreeNode::new("ForEach", "", id_gen.next())
      node.add_child(expr_to_tree(expr, id_gen))
      node.add_child(expr_to_tree(body, id_gen))
      match else_block {
        Some(e) => node.add_child(expr_to_tree(e, id_gen))
        None => ()
      }
      node
    }
    Try(body~, catch_~, try_else~, ..) => {
      let node = TreeNode::new("Try", "", id_gen.next())
      node.add_child(expr_to_tree(body, id_gen))
      for case in catch_ {
        node.add_child(expr_to_tree(case.body, id_gen))
      }
      match try_else {
        Some(cases) =>
          for case in cases {
            node.add_child(expr_to_tree(case.body, id_gen))
          }
        None => ()
      }
      node
    }
    TryOperator(body~, ..) => {
      let node = TreeNode::new("TryOperator", "", id_gen.next())
      node.add_child(expr_to_tree(body, id_gen))
      node
    }
    Map(elems~, ..) => {
      let node = TreeNode::new("Map", "", id_gen.next())
      for elem in elems {
        node.add_child(expr_to_tree(elem.expr, id_gen))
      }
      node
    }
    Group(expr~, ..) => {
      let node = TreeNode::new("Group", "", id_gen.next())
      node.add_child(expr_to_tree(expr, id_gen))
      node
    }
    StaticAssert(body~, ..) => {
      let node = TreeNode::new("StaticAssert", "", id_gen.next())
      node.add_child(expr_to_tree(body, id_gen))
      node
    }
  }
}
