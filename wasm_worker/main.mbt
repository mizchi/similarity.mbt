///|
let ignore_dirs : Array[String] = [
  ".mooncakes", ".git", "_build", "target", "node_modules",
]

///|
let worklist_file = ".wasm_worklist.txt"

///|
fn find_mbt_files(dir : String, result : Array[String]) -> Unit {
  let entries = @fs.read_dir(dir) catch { _ => return }
  for entry in entries {
    let mut should_ignore = false
    for ignored in ignore_dirs {
      if entry == ignored {
        should_ignore = true
        break
      }
    }
    if should_ignore {
      continue
    }
    let path = if dir == "." { entry } else { "\{dir}/\{entry}" }
    let is_dir = @fs.is_dir(path) catch { _ => false }
    if is_dir {
      find_mbt_files(path, result)
    } else if entry.has_suffix(".mbt") {
      result.push(path)
    }
  }
}

///|
fn parse_worklist(contents : String) -> Array[String] {
  let files : Array[String] = []
  for line in contents.split("\n") {
    if line.length() == 0 {
      continue
    }
    files.push(line.to_string())
  }
  files
}

///|
fn load_worklist() -> Array[String]? {
  let contents = @fs.read_file_to_string(worklist_file) catch {
    _ => return None
  }
  let files = parse_worklist(contents)
  if files.is_empty() {
    None
  } else {
    Some(files)
  }
}

///|
fn select_files(
  files : Array[String],
  worker_id : Int,
  worker_total : Int,
) -> Array[String] {
  if worker_total <= 1 {
    return files
  }
  let mut id = worker_id
  if id < 0 {
    id = 0
  }
  let total = if worker_total <= 0 { 1 } else { worker_total }
  let norm = id % total
  let selected : Array[String] = []
  for i, file in files {
    if i % total == norm {
      selected.push(file)
    }
  }
  selected
}

///|
pub fn run(worker_id : Int, worker_total : Int) -> Unit {
  let files = match load_worklist() {
    Some(list) => select_files(list, worker_id, worker_total)
    None => {
      let fallback : Array[String] = []
      find_mbt_files(".", fallback)
      fallback
    }
  }
  let mut total_bytes = 0
  let mut total_funcs = 0
  for file in files {
    let source = @fs.read_file_to_string(file) catch { _ => "" }
    total_bytes = total_bytes + source.length()
    let _ = source
    // Keep worker compile-safe even in builds where extractor is stripped.
    total_funcs = total_funcs + 0
  }
  let _ = total_bytes + total_funcs
}

///|
fn main {
  run(0, 1)
}
