///|
async fn main {
  @cli.run_cli() catch {
    err => println(err.to_string())
  }
}
