//! 〚📁:3f545696-1d7a-5b98-89c6-b3d4eaa00dbf〛 Rust entrypoint :: Thin argv wrapper; forwards args to demo::run_demo.

mod demo;

fn main() {
    let args: Vec<String> = std::env::args().skip(1).collect();
    demo::run_demo(&args);
}
