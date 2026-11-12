//! Platform-independent engine domain boundary.

pub mod catalog_baseline;
pub mod normalization;
pub mod number_wall_frame;
pub mod number_wall_grid;
pub mod number_wall_prime;
pub mod param_interpolation;
pub mod param_randomization;
pub mod physical_events;
pub mod physical_view;
pub mod precision;
pub mod seeded_random;
pub mod session;
pub mod snapshot;
pub mod trajectory;
pub mod view;
pub mod work_queue;

/// Rust engine version, independent of the Flutter app version.
pub fn engine_version() -> String {
    env!("CARGO_PKG_VERSION").to_owned()
}

#[cfg(test)]
mod tests {
    use std::process::Command;

    fn matches_domain_graph(tree: &str, forbidden: &[&str]) -> bool {
        tree.lines().all(|line| {
            let name = line.split_whitespace().next().expect("package name");
            !forbidden.iter().any(|prefix| name.starts_with(prefix))
        })
    }

    #[test]
    fn core_rejects_platform_dependencies() {
        // Reject platform families across normal, build, dev and transitive edges;
        // ordinary pure-Rust math/serialization dependencies are allowed.
        let forbidden = [
            "fractal-bridge",
            "flutter",
            "frb",
            "dart",
            "android",
            "jni",
            "gpui",
            "wgpu",
        ];
        for package in ["fractal-core"] {
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
                matches_domain_graph(&tree, &forbidden),
                "unexpected dependency in {package}: {tree}"
            );
            for dependency in forbidden {
                assert!(!matches_domain_graph(
                    &format!("{tree}{dependency} v0.0.0\n"),
                    &forbidden
                ));
            }
        }
    }
}
