//! Platform-independent engine domain boundary.

/// Rust engine version, independent of the Flutter app version.
pub fn engine_version() -> String {
    env!("CARGO_PKG_VERSION").to_owned()
}

#[cfg(test)]
mod tests {
    use std::process::Command;

    #[test]
    fn core_and_render_reject_platform_dependencies() {
        // Allow only the foundation graph, including optional, target, dev/build edges.
        // Extend this list only when adding approved domain/render dependencies.
        for (package, expected) in [
            ("fractal-core", vec!["fractal-core"]),
            ("fractal-render", vec!["fractal-render", "fractal-core"]),
        ] {
            let output = Command::new(env!("CARGO"))
                .current_dir(env!("CARGO_MANIFEST_DIR"))
                .args([
                    "tree",
                    "--package",
                    package,
                    "--edges",
                    "normal,build,dev",
                    "--prefix",
                    "none",
                    "--target",
                    "all",
                    "--all-features",
                    "--locked",
                    "--offline",
                ])
                .output()
                .expect("cargo tree must run");
            assert!(
                output.status.success(),
                "cargo tree failed: {}",
                String::from_utf8_lossy(&output.stderr)
            );
            let tree = String::from_utf8(output.stdout).expect("cargo tree emits UTF-8");
            let actual: Vec<_> = tree
                .lines()
                .map(|line| line.split_whitespace().next().expect("package name"))
                .collect();
            assert_eq!(actual, expected, "unexpected dependency in {package}");
        }
    }
}
