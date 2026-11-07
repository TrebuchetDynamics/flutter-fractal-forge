//! Platform-independent engine domain boundary.

pub mod catalog_baseline;
pub mod normalization;

/// Rust engine version, independent of the Flutter app version.
pub fn engine_version() -> String {
    env!("CARGO_PKG_VERSION").to_owned()
}

#[cfg(test)]
mod tests {
    use std::{collections::BTreeSet, process::Command};

    fn matches_domain_graph(tree: &str, expected: &[&str]) -> bool {
        let actual: BTreeSet<_> = tree
            .lines()
            .map(|line| line.split_whitespace().next().expect("package name"))
            .collect();
        actual == expected.iter().copied().collect()
    }

    #[test]
    fn core_and_render_reject_platform_dependencies() {
        // Allow only the locked pure-domain serde graph across all edge kinds.
        let core_graph = [
            "fractal-core",
            "serde",
            "serde_core",
            "serde_derive",
            "serde_json",
            "proc-macro2",
            "quote",
            "syn",
            "unicode-ident",
            "itoa",
            "ryu",
        ];
        for package in ["fractal-core", "fractal-render"] {
            let mut expected = core_graph.to_vec();
            if package == "fractal-render" {
                expected.push("fractal-render");
            }
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
            assert!(
                matches_domain_graph(&tree, &expected),
                "unexpected dependency in {package}: {tree}"
            );
            for forbidden in ["flutter_rust_bridge", "android-activity", "gpui"] {
                assert!(!matches_domain_graph(
                    &format!("{tree}{forbidden} v0.0.0\n"),
                    &expected
                ));
            }
        }
    }
}
