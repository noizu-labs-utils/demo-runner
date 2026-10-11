//! demo-runner — Typewriter-style scripted terminal demo player.
//!
//! Reads a `.demo` script and plays it back: headings appear instantly,
//! `$ command` lines are typed character-by-character and then executed.
//!
//! Extracted from noizu/tabbing-on (rust/src/demo.rs), where this ran as
//! an argv0 applet of the `tabbing-on` binary. Here it is a standalone
//! binary with its own `main()`. The shell implementation under `shell/`
//! is the reference; this crate is a leaner port (see the parity matrix
//! in the repository README for what it does not implement).

use std::fs;
use std::io::{self, stdout, BufRead, Write};
use std::process::Command;
use std::thread;
use std::time::Duration;

// ANSI escape codes
const BOLD_CYAN: &str = "\x1b[1;36m";
const DIM: &str = "\x1b[2m";
const GREEN: &str = "\x1b[32m";
const BOLD_GREEN: &str = "\x1b[1;32m";
const YELLOW: &str = "\x1b[33m";
const CYAN: &str = "\x1b[36m";
const RESET: &str = "\x1b[0m";

#[derive(Clone, Copy)]
enum Speed {
    Fast,
    Medium,
    Slow,
}

impl Speed {
    fn char_delay_ms(self) -> u64 {
        match self {
            Speed::Fast => 15,
            Speed::Medium => 30,
            Speed::Slow => 60,
        }
    }

    fn from_str(s: &str) -> Option<Speed> {
        match s {
            "fast" => Some(Speed::Fast),
            "medium" => Some(Speed::Medium),
            "slow" => Some(Speed::Slow),
            _ => None,
        }
    }
}

/// One parsed line of a .demo script. Extracted so the dispatch order is
/// unit-testable and mirrored exactly by the contract-test suite.
#[derive(Debug, PartialEq)]
enum Line<'a> {
    Description(&'a str), // "## text"
    Heading(&'a str),     // "# text"
    Command(&'a str),     // "$ command"
    Sleep(&'a str),       // "@sleep N" (raw seconds text)
    Prompt(&'a str),      // "@prompt" or "@prompt text"
    Input(&'a str),       // "@input text"
    Clear,                // "@clear"
    SpeedChange(&'a str), // "@speed fast|medium|slow" (raw value)
    Blank,
    Verbatim(&'a str), // anything else, printed as-is
}

fn classify_line(line: &str) -> Line<'_> {
    if let Some(text) = line.strip_prefix("## ") {
        // Check before single # to avoid ambiguity
        Line::Description(text)
    } else if let Some(text) = line.strip_prefix("# ") {
        Line::Heading(text)
    } else if let Some(text) = line.strip_prefix("$ ") {
        Line::Command(text)
    } else if let Some(text) = line.strip_prefix("@sleep ") {
        Line::Sleep(text)
    } else if line == "@prompt" {
        Line::Prompt("")
    } else if let Some(text) = line.strip_prefix("@prompt ") {
        Line::Prompt(text)
    } else if let Some(text) = line.strip_prefix("@input ") {
        Line::Input(text)
    } else if line == "@clear" {
        Line::Clear
    } else if let Some(text) = line.strip_prefix("@speed ") {
        Line::SpeedChange(text)
    } else if line.is_empty() {
        Line::Blank
    } else {
        Line::Verbatim(line)
    }
}

fn type_text(text: &str, delay_ms: u64) {
    let mut out = stdout();
    for ch in text.chars() {
        print!("{}", ch);
        let _ = out.flush();
        // Vary delay slightly for natural feel: ~1 in 3 chars gets 2x delay
        let actual_delay = if fastrand_simple(3) == 0 {
            delay_ms * 2
        } else {
            delay_ms
        };
        thread::sleep(Duration::from_millis(actual_delay));
    }
    println!();
}

/// Simple deterministic-ish "random" without pulling in a crate.
/// Uses a thread-local counter seeded from the current time.
fn fastrand_simple(modulus: u64) -> u64 {
    use std::cell::Cell;
    thread_local! {
        static STATE: Cell<u64> = Cell::new(
            std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap_or_default()
                .as_nanos() as u64
        );
    }
    STATE.with(|s| {
        // xorshift64
        let mut x = s.get();
        x ^= x << 13;
        x ^= x >> 7;
        x ^= x << 17;
        s.set(x);
        x % modulus
    })
}

fn wait_for_enter(prompt: &str) {
    let prompt_text = if prompt.is_empty() {
        "Press Enter to continue..."
    } else {
        prompt
    };
    print!("\n{}{}{} ", YELLOW, prompt_text, RESET);
    let _ = stdout().flush();
    let mut buf = String::new();
    let _ = io::stdin().lock().read_line(&mut buf);
}

fn show_heading(text: &str) {
    let underline: String = "\u{2500}".repeat(text.chars().count());
    println!("\n{}{}{}", BOLD_CYAN, text, RESET);
    println!("{}{}{}", CYAN, underline, RESET);
}

fn show_description(text: &str) {
    println!("{}{}{}", DIM, text, RESET);
}

fn run_command(command: &str, speed: Speed) {
    // Print the prompt
    print!("{}{}${} ", BOLD_GREEN, GREEN, RESET);
    let _ = stdout().flush();

    // Type out the command character by character
    type_text(command, speed.char_delay_ms());

    // Brief pause before execution (like a real terminal)
    thread::sleep(Duration::from_millis(100));

    // Execute via sh -c
    let _ = Command::new("sh").arg("-c").arg(command).status();

    // Blank line after output
    println!();
}

fn print_help() {
    println!("demo-runner \u{2014} Typewriter-style .demo file player");
    println!();
    println!("Usage: demo-runner [--speed fast|medium|slow] <file.demo>");
    println!();
    println!("Markup:");
    println!("  # Heading          Bold cyan section heading");
    println!("  ## Description     Dim description text");
    println!("  $ command          Type and execute a shell command");
    println!("  @sleep N           Pause N seconds");
    println!("  @prompt Text       Show text, wait for Enter");
    println!("  @clear             Clear screen");
    println!("  @speed fast|medium|slow  Change typing speed");
}

pub fn run_demo(args: &[String]) {
    let mut speed = Speed::Medium;
    let mut file_path: Option<String> = None;

    // Parse arguments
    let mut i = 0;
    while i < args.len() {
        match args[i].as_str() {
            "--help" | "-h" => {
                print_help();
                return;
            }
            "--speed" => {
                i += 1;
                if i < args.len() {
                    if let Some(s) = Speed::from_str(&args[i]) {
                        speed = s;
                    } else {
                        eprintln!(
                            "demo-runner: unknown speed '{}' (use fast|medium|slow)",
                            args[i]
                        );
                        std::process::exit(1);
                    }
                }
            }
            s if s.starts_with("--speed=") => {
                let val = s.strip_prefix("--speed=").unwrap();
                if let Some(s) = Speed::from_str(val) {
                    speed = s;
                } else {
                    eprintln!(
                        "demo-runner: unknown speed '{}' (use fast|medium|slow)",
                        val
                    );
                    std::process::exit(1);
                }
            }
            "--fast" => speed = Speed::Fast,
            "--slow" => speed = Speed::Slow,
            _ => {
                if file_path.is_none() {
                    file_path = Some(args[i].clone());
                } else {
                    eprintln!("demo-runner: unexpected argument '{}'", args[i]);
                    std::process::exit(1);
                }
            }
        }
        i += 1;
    }

    let path = match file_path {
        Some(p) => p,
        None => {
            print_help();
            return;
        }
    };

    let content = match fs::read_to_string(&path) {
        Ok(c) => c,
        Err(e) => {
            eprintln!("demo-runner: cannot read '{}': {}", path, e);
            std::process::exit(1);
        }
    };

    // Process line by line
    for line in content.lines() {
        match classify_line(line) {
            Line::Description(text) => show_description(text),
            Line::Heading(text) => show_heading(text),
            Line::Command(command) => run_command(command, speed),
            Line::Sleep(secs_str) => {
                if let Ok(secs) = secs_str.trim().parse::<f64>() {
                    thread::sleep(Duration::from_millis((secs * 1000.0) as u64));
                }
            }
            Line::Prompt(text) => wait_for_enter(text),
            Line::Input(text) => {
                // Simulate typing text (visual only)
                type_text(text, speed.char_delay_ms());
            }
            Line::Clear => {
                // Clear screen
                print!("\x1b[2J\x1b[H");
                let _ = stdout().flush();
            }
            Line::SpeedChange(val) => {
                if let Some(s) = Speed::from_str(val.trim()) {
                    speed = s;
                }
            }
            Line::Blank => println!(),
            Line::Verbatim(text) => println!("{}", text),
        }
    }

    // Final
    println!("\n{}{}Done!{}", BOLD_GREEN, GREEN, RESET);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_speed_from_str() {
        assert!(Speed::from_str("fast").is_some());
        assert!(Speed::from_str("medium").is_some());
        assert!(Speed::from_str("slow").is_some());
        assert!(Speed::from_str("turbo").is_none());
    }

    #[test]
    fn test_speed_delays() {
        assert_eq!(Speed::Fast.char_delay_ms(), 15);
        assert_eq!(Speed::Medium.char_delay_ms(), 30);
        assert_eq!(Speed::Slow.char_delay_ms(), 60);
    }

    #[test]
    fn test_fastrand_simple_bounded() {
        for _ in 0..100 {
            let val = fastrand_simple(3);
            assert!(val < 3);
        }
    }

    #[test]
    fn test_classify_headings_and_descriptions() {
        assert_eq!(classify_line("# Title"), Line::Heading("Title"));
        assert_eq!(classify_line("## Subtitle"), Line::Description("Subtitle"));
        // "##" must win over "#" (checked first)
        assert_eq!(classify_line("## x"), Line::Description("x"));
        // Bare "#" / "##" without trailing space are verbatim
        assert_eq!(classify_line("#"), Line::Verbatim("#"));
        assert_eq!(classify_line("##"), Line::Verbatim("##"));
    }

    #[test]
    fn test_classify_commands_and_directives() {
        assert_eq!(classify_line("$ echo hi"), Line::Command("echo hi"));
        assert_eq!(classify_line("@sleep 2"), Line::Sleep("2"));
        assert_eq!(classify_line("@sleep 0.5"), Line::Sleep("0.5"));
        assert_eq!(classify_line("@prompt"), Line::Prompt(""));
        assert_eq!(
            classify_line("@prompt Press Enter"),
            Line::Prompt("Press Enter")
        );
        assert_eq!(classify_line("@input y"), Line::Input("y"));
        assert_eq!(classify_line("@clear"), Line::Clear);
        assert_eq!(classify_line("@speed fast"), Line::SpeedChange("fast"));
    }

    #[test]
    fn test_classify_edge_cases() {
        assert_eq!(classify_line(""), Line::Blank);
        assert_eq!(classify_line("plain text"), Line::Verbatim("plain text"));
        // Lookalike directives without the trailing space stay verbatim
        assert_eq!(classify_line("@sleep"), Line::Verbatim("@sleep"));
        assert_eq!(classify_line("@input"), Line::Verbatim("@input"));
        assert_eq!(classify_line("@cleared"), Line::Verbatim("@cleared"));
        // Multibyte prompt text must not panic (byte-slice safe)
        assert_eq!(classify_line("@prompt ü"), Line::Prompt("ü"));
    }
}
