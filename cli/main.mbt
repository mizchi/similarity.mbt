///|
/// Similarity detection CLI (single binary)
///
/// Usage: similarity-mbt [OPTIONS] [files...]
///
/// Options:
///   -t <value>   Similarity threshold (0.0-1.0, default: 0.8)
///   -w <count>   Number of parallel workers (default: 4)
///   -m <lines>   Minimum function lines (default: 3)
///   -h           Show help
///
/// If no files specified, searches for **/*.mbt in current directory
/// (excluding .mooncakes and .git directories)

///|
/// Directories to ignore when searching for .mbt files
let ignore_dirs : Array[String] = [
  ".mooncakes", ".git", "_build", "target", "node_modules",
]

///|
struct Config {
  threshold : Double
  workers : Int
  min_lines : Int
  files : Array[String]
  no_tests : Bool
}

///|
/// Use git ls-files to get tracked .mbt files (respects .gitignore)
async fn find_mbt_files_git(result : Array[String]) -> Bool {
  let (exit_code, stdout, _stderr) = @process.collect_output(
    "git",
    ["ls-files", "*.mbt", "**/*.mbt"],
  )
  if exit_code != 0 {
    return false
  }
  let decoder = @encoding.decoder(UTF8)
  let output = decoder.decode_lossy(stdout.binary())
  for line in output.split("\n") {
    let file = line.trim().to_string()
    if file.length() > 0 && file.has_suffix(".mbt") {
      // Only include files that exist (git ls-files may include deleted files)
      if @fs.path_exists(file) {
        result.push(file)
      }
    }
  }
  true
}

///|
/// Recursively find all .mbt files in directory, excluding ignored dirs
/// Fallback when git is not available
fn find_mbt_files(dir : String, result : Array[String]) -> Unit {
  let entries = @fs.read_dir(dir) catch { _ => return }
  for entry in entries {
    // Skip ignored directories
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
fn is_test_file(filename : String) -> Bool {
  filename.has_suffix("_test.mbt") || filename.has_suffix("_wbtest.mbt")
}

///|
/// Check if a path contains any ignored directory
fn should_ignore_path(path : String) -> Bool {
  for ignored in ignore_dirs {
    if path.contains("/\{ignored}/") || path.has_prefix("\{ignored}/") {
      return true
    }
  }
  false
}

///|
fn parse_args() -> Config? {
  let args = @env.args()
  let mut threshold = 0.8
  let mut workers = 4
  let mut min_lines = 3
  let mut no_tests = false
  let files : Array[String] = []
  let mut i = 1
  while i < args.length() {
    let arg = args[i]
    if arg == "-h" || arg == "--help" {
      print_help()
      return None
    } else if arg == "-t" || arg == "--threshold" {
      i = i + 1
      if i < args.length() {
        threshold = @strconv.parse_double(args[i]) catch { _ => 0.8 }
      }
    } else if arg == "-w" || arg == "--workers" {
      i = i + 1
      if i < args.length() {
        workers = @strconv.parse_int(args[i]) catch { _ => 4 }
      }
    } else if arg == "-m" || arg == "--min-lines" {
      i = i + 1
      if i < args.length() {
        min_lines = @strconv.parse_int(args[i]) catch { _ => 3 }
      }
    } else if arg == "--no-tests" {
      no_tests = true
    } else if not(arg.has_prefix("-")) {
      files.push(arg)
    }
    i = i + 1
  }
  // Filter files: remove ignored directories and optionally test files
  let filtered_files : Array[String] = []
  for file in files {
    // Skip files in ignored directories
    if should_ignore_path(file) {
      continue
    }
    // Skip test files if --no-tests is set
    if no_tests && is_test_file(file) {
      continue
    }
    filtered_files.push(file)
  }
  Some(Config::{ threshold, workers, min_lines, files: filtered_files, no_tests })
}

///|
/// Discover files when none are specified (async to support git ls-files)
async fn discover_files(config : Config) -> Config {
  if config.files.is_empty() {
    let files : Array[String] = []
    // Try git ls-files first (respects .gitignore)
    let git_success = find_mbt_files_git(files)
    if not(git_success) || files.is_empty() {
      // Fallback to directory traversal
      find_mbt_files(".", files)
    }
    // Apply filtering
    let filtered : Array[String] = []
    for file in files {
      if should_ignore_path(file) {
        continue
      }
      if config.no_tests && is_test_file(file) {
        continue
      }
      filtered.push(file)
    }
    Config::{ ..config, files: filtered }
  } else {
    config
  }
}

///|
fn print_help() -> Unit {
  println("similarity-mbt - MoonBit code similarity detection")
  println("")
  println("Usage: similarity-mbt [OPTIONS] [files...]")
  println("")
  println("Arguments:")
  println("  files        MoonBit source files (default: **/*.mbt)")
  println("")
  println("Options:")
  println("  -t <value>   Similarity threshold (0.0-1.0, default: 0.8)")
  println("  -w <count>   Number of parallel workers (default: 4)")
  println("  -m <lines>   Minimum function lines (default: 3)")
  println("  --no-tests   Exclude test files (*_test.mbt, *_wbtest.mbt)")
  println("  -h           Show this help message")
  println("")
  println("Ignored directories: .mooncakes, .git, _build, target, node_modules")
  println("")
  println("Examples:")
  println("  similarity-mbt                   # All .mbt files in current dir")
  println("  similarity-mbt -t 0.9            # With 90% threshold")
  println("  similarity-mbt --no-tests        # Exclude test files")
  println("  similarity-mbt -w 8 src/*.mbt    # Specific files with 8 workers")
}

///|
/// Worker mode: compare two files and output results
fn run_worker_mode(file1 : String, file2 : String, threshold : Double) -> Unit {
  let source1 = @fs.read_file_to_string(file1) catch {
    e => {
      println("Error reading \{file1}: \{e}")
      return
    }
  }
  let source2 = @fs.read_file_to_string(file2) catch {
    e => {
      println("Error reading \{file2}: \{e}")
      return
    }
  }
  let funcs1 = @lib.extract_functions(source1)
  let funcs2 = @lib.extract_functions(source2)
  let tsed_options : @lib.TSEDOptions = {
    apted_options: @lib.APTEDOptions::default(),
    min_lines: 3,
    min_tokens: None,
    size_penalty: true,
  }
  let mut found = false
  for f1 in funcs1 {
    for f2 in funcs2 {
      let lines1 = f1.end_line - f1.start_line + 1
      let lines2 = f2.end_line - f2.start_line + 1
      if lines1 < 3 || lines2 < 3 {
        continue
      }
      let similarity = @lib.calculate_tsed(f1.tree, f2.tree, tsed_options)
      if similarity >= threshold {
        found = true
        let pct = (similarity * 100.0).to_int()
        println(
          "\{file1}:\{f1.start_line}:\{f1.name} <-> \{file2}:\{f2.start_line}:\{f2.name} (\{pct}%)",
        )
      }
    }
  }
  if not(found) {
    println("NO_MATCHES")
  }
}

///|
/// Analyze a single file for similar functions
fn analyze_single_file(
  file : String,
  threshold : Double,
  min_lines : Int,
) -> Unit {
  let source = @fs.read_file_to_string(file) catch {
    e => {
      println("Error reading \{file}: \{e}")
      return
    }
  }
  let options : @lib.DetectorOptions = {
    threshold,
    min_lines,
    size_penalty: true,
  }
  let results = @lib.detect_similarities(source, options)
  if results.is_empty() {
    println("No similar functions found in \{file}")
  } else {
    for result in results {
      let pct = (result.similarity * 100.0).to_int()
      println(
        "\{file}:\{result.func1.start_line}:\{result.func1.name} <-> \{file}:\{result.func2.start_line}:\{result.func2.name} (\{pct}%)",
      )
    }
  }
}

///|
/// Analyze multiple files for similar functions (parallel)
async fn analyze_multiple_files(config : Config) -> Unit {
  let args = @env.args()
  let self_path = args[0] // Path to this binary
  let files = config.files

  // Generate all file pairs
  let pairs : Array[(String, String)] = []
  for i = 0; i < files.length(); i = i + 1 {
    for j = i + 1; j < files.length(); j = j + 1 {
      pairs.push((files[i], files[j]))
    }
  }
  println(
    "Comparing \{pairs.length()} file pairs (\{files.length()} files) using \{config.workers} workers...",
  )
  println("")
  let pool = @pool.ProcessPool::new(max_workers=config.workers)
  let start = @pool.now()
  let threshold_str = config.threshold.to_string()

  // Spawn self as worker with --internal-worker flag
  let results = pool.map(pairs, fn(pair) {
    let (file1, file2) = pair
    @pool.job(self_path, ["--internal-worker", file1, file2, threshold_str])
  })
  let elapsed = @pool.now() - start

  // Collect and print results
  let mut total_matches = 0
  let mut errors = 0
  for result in results {
    if result.exit_code == 0 {
      let output = result.stdout.trim().to_string()
      if output != "NO_MATCHES" && output.length() > 0 {
        println(output)
        // Count matches
        for c in output.iter() {
          if c == '\n' {
            total_matches = total_matches + 1
          }
        }
        total_matches = total_matches + 1
      }
    } else {
      errors = errors + 1
      if result.stderr.length() > 0 {
        println("Error: \{result.stderr}")
      }
    }
  }
  println("")
  println("=== Summary ===")
  println("Files: \{files.length()}")
  println("Pairs: \{pairs.length()}")
  println("Matches: \{total_matches}")
  println("Time: \{elapsed}ms")
  if errors > 0 {
    println("Errors: \{errors}")
  }
}

///|
async fn main {
  let args = @env.args()

  // Check for internal worker mode
  if args.length() >= 5 && args[1] == "--internal-worker" {
    let file1 = args[2]
    let file2 = args[3]
    let threshold = @strconv.parse_double(args[4]) catch { _ => 0.8 }
    run_worker_mode(file1, file2, threshold)
    return
  }

  // Main process mode
  let config = parse_args()
  match config {
    None => return
    Some(cfg) => {
      // Discover files if none specified (uses git ls-files if available)
      let cfg = discover_files(cfg)
      if cfg.files.is_empty() {
        println("No .mbt files found")
        return
      }
      if cfg.files.length() == 1 {
        // Single file: analyze within the file
        analyze_single_file(cfg.files[0], cfg.threshold, cfg.min_lines)
      } else {
        // Multiple files: parallel comparison using self as worker
        analyze_multiple_files(cfg)
      }
    }
  }
}
