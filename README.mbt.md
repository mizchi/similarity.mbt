# similarity.mbt

Code similarity detection for MoonBit using AST-based comparison (TSED - Tree Structure Edit Distance).

## Features

- **AST-based comparison** - Uses `moonbitlang/parser` to parse MoonBit code
- **TSED Algorithm** - Tree Structure Edit Distance for accurate structural similarity
- **Function extraction** - Extracts functions, methods, and tests from MoonBit source
- **Cross-file detection** - Compare functions across multiple files

## Installation

### CLI Tool

```bash
git clone https://github.com/mizchi/similarity.mbt
cd similarity.mbt
make install  # Installs to ~/.local/bin/similarity-mbt
```

Make sure `~/.local/bin` is in your `PATH`.

### As a Library

Add to your `moon.mod.json`:

```json
{
  "deps": {
    "mizchi/similarity": "0.1.0"
  }
}
```

## Usage

### CLI

```bash
# Scan all .mbt files in current directory
similarity-mbt

# Scan specific files
similarity-mbt src/*.mbt

# Adjust threshold (default: 0.88)
similarity-mbt -t 0.95 *.mbt

# Exclude test files
similarity-mbt --no-tests

# Show help
similarity-mbt -h
```

### Basic similarity detection (Library)

```moonbit
let source = 
  #|fn add(a : Int, b : Int) -> Int { a + b }
  #|fn sum(x : Int, y : Int) -> Int { x + y }

let options = @similarity.DetectorOptions::default()
let results = @similarity.detect_similarities(source, options)

for result in results {
  println(result)  // add <-> sum (similarity: 95%, score: 2.8)
}
```

### Custom options

```moonbit
///|
let options : @similarity.DetectorOptions = {
  threshold: 0.80, // Minimum similarity (0.0-1.0)
  min_lines: 3, // Minimum lines per function
  size_penalty: true, // Penalize size differences
}
```

### Cross-file comparison

```moonbit
let files = [
  ("file1.mbt", source1),
  ("file2.mbt", source2),
]
let results = @similarity.detect_cross_file_similarities(files, options)

for result in results {
  let (file1, file2, sim) = result
  println("\{file1}:\{sim.func1.name} <-> \{file2}:\{sim.func2.name}")
}
```

### Direct tree comparison

```moonbit
///|
let functions = @similarity.extract_functions(source)

///|
let tsed_options = @similarity.TSEDOptions::default()

///|
let similarity = @similarity.calculate_tsed(
  functions[0].tree,
  functions[1].tree,
  tsed_options,
)
```

## API

### Types

- `DetectorOptions` - Configuration for similarity detection
- `FunctionInfo` - Extracted function with name, line info, and AST tree
- `SimilarityResult` - Comparison result with similarity score
- `TreeNode` - AST tree node for TSED comparison

### Functions

- `detect_similarities(source, options)` - Detect similar functions in source
- `detect_cross_file_similarities(sources, options)` - Cross-file comparison
- `extract_functions(source)` - Extract functions from source code
- `calculate_tsed(tree1, tree2, options)` - Calculate tree edit distance

## Algorithm

Based on APTED (All Path Tree Edit Distance) with TSED normalization:

1. **Parse** - Convert MoonBit source to AST using `moonbitlang/parser`
2. **Extract** - Extract function bodies as tree structures
3. **Compare** - Calculate edit distance between trees
4. **Normalize** - Apply size penalties and normalization

## License

Apache-2.0
