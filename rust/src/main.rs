mod demo;

fn main() {
    let args: Vec<String> = std::env::args().skip(1).collect();
    demo::run_demo(&args);
}
