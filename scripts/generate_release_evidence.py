#!/usr/bin/env python3
"""Generate and verify release-bound manifests, checksums, SBOM, and notices."""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import os
import shutil
import subprocess
import sys
import uuid
from pathlib import Path
from typing import Any


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def select_artifacts_for_identity(
    artifact_dir: Path,
    *,
    version: str,
    build_number: str,
    commit: str,
    required_names: set[str] | None = None,
) -> list[Path]:
    """Return only staged artifacts bound to the requested release identity."""
    artifact_dir = artifact_dir.resolve()
    selected: list[Path] = []
    for artifact in sorted(artifact_dir.iterdir()):
        if not artifact.name.endswith((".aab", ".apk", ".tar.gz", ".zip")):
            continue
        if artifact.is_symlink():
            raise ValueError(f"release artifact must not be a symbolic link: {artifact}")
        if not artifact.is_file():
            continue
        provenance = Path(f"{artifact}.provenance")
        if not provenance.is_file():
            continue
        if provenance.is_symlink():
            raise ValueError(f"artifact provenance must not be a symbolic link: {provenance}")
        fields: dict[str, str] = {}
        for line in provenance.read_text(encoding="utf-8").splitlines():
            if "=" in line:
                key, value = line.split("=", 1)
                fields[key] = value
        if (
            fields.get("version") == version
            and fields.get("build_number") == build_number
            and fields.get("commit") == commit
        ):
            selected.append(artifact.resolve())
    if required_names is not None:
        selected_by_name = {artifact.name: artifact for artifact in selected}
        missing = sorted(required_names - selected_by_name.keys())
        if missing:
            raise ValueError(
                "required artifact set mismatch: "
                f"missing={missing}"
            )
        selected = [selected_by_name[name] for name in sorted(required_names)]
    return selected


def project_version(project_root: Path) -> str:
    for line in (project_root / "pubspec.yaml").read_text(encoding="utf-8").splitlines():
        if line.startswith("version:"):
            version = line.split(":", 1)[1].strip().strip("'\"")
            if version:
                return version
    raise ValueError("pubspec.yaml does not declare a version")


def dependency_components(project_root: Path) -> list[dict[str, Any]]:
    packages: dict[str, dict[str, str]] = {}
    current: dict[str, str] | None = None
    for line in (project_root / "pubspec.lock").read_text(encoding="utf-8").splitlines():
        if line.startswith("  ") and not line.startswith("    ") and line.rstrip().endswith(":"):
            name = line.strip()[:-1]
            current = packages.setdefault(name, {})
            continue
        if current is None:
            continue
        stripped = line.strip()
        for key in ("dependency", "source", "version", "sha256"):
            prefix = f"{key}:"
            if stripped.startswith(prefix):
                current[key] = stripped.split(":", 1)[1].strip().strip("'\"")
                break

    components: list[dict[str, Any]] = []
    for name, package in sorted(packages.items()):
        if package.get("source") == "sdk":
            continue
        version = str(package.get("version", "unknown"))
        component: dict[str, Any] = {
            "type": "library",
            "name": name,
            "version": version,
            "purl": f"pkg:pub/{name}@{version}",
            "properties": [
                {"name": "pub:dependency", "value": str(package.get("dependency", "unknown"))},
                {"name": "pub:source", "value": str(package.get("source", "unknown"))},
            ],
        }
        locked_hash = package.get("sha256")
        if locked_hash:
            component["hashes"] = [{"alg": "SHA-256", "content": locked_hash}]
        components.append(component)
    return components


def license_text(name: str, version: str) -> str:
    package_dir = Path.home() / ".pub-cache" / "hosted" / "pub.dev" / f"{name}-{version}"
    for candidate_name in ("LICENSE", "LICENSE.txt", "LICENSE.md", "COPYING"):
        candidate = package_dir / candidate_name
        if candidate.is_file():
            return candidate.read_text(encoding="utf-8", errors="replace").strip()
    raise ValueError(
        f"Missing license text for {name} {version}; run flutter pub get or resolve the dependency license before release"
    )


def native_declaration_inventory(project_root: Path) -> str:
    """Inventory checked-in Android/desktop native dependency declarations.

    This deliberately does not claim to be a resolved transitive native SBOM.
    Flutter plugin packages remain represented in the CycloneDX Pub inventory.
    """
    candidates = [
        *sorted((project_root / "android").glob("**/*.gradle")),
        *sorted((project_root / "android").glob("**/*.gradle.kts")),
        *sorted((project_root / "linux").glob("**/CMakeLists.txt")),
        *sorted((project_root / "windows").glob("**/CMakeLists.txt")),
    ]
    lines = [
        "Fractal Forge Android/native declaration inventory",
        "Scope: checked-in Gradle and CMake declarations; not a resolved transitive native SBOM.",
        "Flutter plugins and Dart packages are inventoried in sbom.cdx.json.",
        "",
    ]
    for path in (candidate for candidate in candidates if candidate.is_file()):
        relative = path.relative_to(project_root).as_posix()
        declarations = [
            line.strip()
            for line in path.read_text(encoding="utf-8", errors="replace").splitlines()
            if any(token in line for token in ("id(", "id ", "implementation(", "classpath(", "find_package(", "include("))
        ]
        if declarations:
            lines.append(f"===== {relative} =====")
            lines.extend(declarations)
            lines.append("")
    if not any(line.startswith("=====") for line in lines):
        lines.append("No checked-in native dependency declarations found.")
    return "\n".join(lines)


def generated_at() -> str:
    epoch = os.environ.get("SOURCE_DATE_EPOCH")
    instant = (
        dt.datetime.fromtimestamp(int(epoch), tz=dt.timezone.utc)
        if epoch
        else dt.datetime.now(tz=dt.timezone.utc)
    )
    return instant.isoformat().replace("+00:00", "Z")


def git_commit(project_root: Path) -> str:
    return subprocess.check_output(
        ["git", "rev-parse", "HEAD"], cwd=project_root, text=True
    ).strip()


def generate(args: argparse.Namespace) -> None:
    project_root = Path(args.project_root).resolve()
    output_dir = Path(args.output_dir).resolve()
    artifact_inputs = [Path(value) for value in args.artifact]
    for artifact in artifact_inputs:
        if artifact.is_symlink():
            raise ValueError(f"release artifact must not be a symbolic link: {artifact}")
    artifacts = [artifact.resolve() for artifact in artifact_inputs]
    for artifact in artifacts:
        if not artifact.is_file():
            raise FileNotFoundError(f"Release artifact not found: {artifact}")
    output_dir.mkdir(parents=True, exist_ok=True)

    extra_evidence: dict[str, str] = {}
    for specification in args.evidence:
        try:
            name, source_value = specification.split("=", 1)
        except ValueError as error:
            raise ValueError("--evidence must use NAME=PATH") from error
        if not name or not name.replace("-", "").replace("_", "").isalnum():
            raise ValueError(f"invalid evidence name: {name!r}")
        source_input = Path(source_value)
        if source_input.is_symlink():
            raise ValueError(
                f"release evidence must not be a symbolic link: {source_input}"
            )
        source = source_input.resolve()
        if not source.is_file():
            raise FileNotFoundError(f"Evidence file not found: {source}")
        destination_name = f"{name}{source.suffix or '.txt'}"
        (output_dir / destination_name).write_bytes(source.read_bytes())
        extra_evidence[name] = destination_name

    version = args.version or project_version(project_root)
    commit = args.commit or git_commit(project_root)
    timestamp = generated_at()
    artifact_records = [
        {
            "name": artifact.name,
            "path": Path(os.path.relpath(artifact, start=output_dir)).as_posix(),
            "bytes": artifact.stat().st_size,
            "sha256": sha256_file(artifact),
        }
        for artifact in artifacts
    ]
    components = dependency_components(project_root)

    manifest = {
        "schemaVersion": 1,
        "application": "Fractal Forge",
        "package": "com.trebuchetdynamics.fractal.forge",
        "version": version,
        "commit": commit,
        "generatedAt": timestamp,
        "artifacts": artifact_records,
        "evidence": {
            "sbom": "sbom.cdx.json",
            "androidNativeInventory": "ANDROID_NATIVE_INVENTORY.txt",
            "thirdPartyNotices": "THIRD_PARTY_NOTICES.txt",
            "checksums": "SHA256SUMS",
            **extra_evidence,
        },
    }
    if args.build_number:
        manifest["buildNumber"] = str(args.build_number)
    sbom = {
        "bomFormat": "CycloneDX",
        "specVersion": "1.5",
        "serialNumber": f"urn:uuid:{uuid.uuid5(uuid.NAMESPACE_URL, f'fractal-forge:{commit}:{version}')}",
        "version": 1,
        "metadata": {
            "timestamp": timestamp,
            "component": {
                "type": "application",
                "name": "Fractal Forge",
                "version": version,
            },
            "properties": [
                {"name": "vcs:commit", "value": commit},
                {
                    "name": "fractal-forge:sbom-scope",
                    "value": "Dart/Flutter packages from pubspec.lock; Android and native inventories are separate evidence files",
                },
            ],
        },
        "components": components,
    }

    (output_dir / "release-manifest.json").write_text(
        json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )
    (output_dir / "sbom.cdx.json").write_text(
        json.dumps(sbom, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )
    notices = [
        "Fractal Forge third-party notices",
        f"Generated for {version} at commit {commit}",
        "",
    ]
    for component in components:
        notices.extend(
            [
                f"===== {component['name']} {component['version']} =====",
                license_text(component["name"], component["version"]),
                "",
            ]
        )
    (output_dir / "THIRD_PARTY_NOTICES.txt").write_text(
        "\n".join(notices), encoding="utf-8"
    )
    (output_dir / "ANDROID_NATIVE_INVENTORY.txt").write_text(
        native_declaration_inventory(project_root), encoding="utf-8"
    )
    checksum_lines = [
        f"{record['sha256']}  {record['path']}" for record in artifact_records
    ]
    for evidence_name in (
        "release-manifest.json",
        "sbom.cdx.json",
        "THIRD_PARTY_NOTICES.txt",
        "ANDROID_NATIVE_INVENTORY.txt",
        *extra_evidence.values(),
    ):
        checksum_lines.append(
            f"{sha256_file(output_dir / evidence_name)}  {evidence_name}"
        )
    (output_dir / "SHA256SUMS").write_text(
        "\n".join(checksum_lines) + "\n", encoding="utf-8"
    )
    print(f"Generated release evidence in {output_dir}")


def verify(
    manifest_path: Path,
    *,
    announce: bool = True,
    manifest: dict[str, Any] | None = None,
) -> None:
    manifest_path = manifest_path.resolve()
    if manifest is None:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    assert manifest is not None
    failures: list[str] = []
    for field in ("version", "buildNumber", "commit", "generatedAt", "artifacts", "evidence"):
        if field not in manifest:
            failures.append(f"missing manifest field: {field}")
    artifacts = manifest.get("artifacts")
    if not isinstance(artifacts, list) or not artifacts:
        failures.append("manifest must contain at least one artifact")
        artifacts = []
    expected_checksum_paths: set[str] = set()
    for artifact in artifacts:
        if not isinstance(artifact, dict) or not all(
            field in artifact for field in ("path", "bytes", "sha256")
        ):
            failures.append(f"malformed artifact record: {artifact!r}")
            continue
        expected_checksum_paths.add(str(artifact["path"]))
        path = Path(artifact["path"])
        if not path.is_absolute():
            path = manifest_path.parent / path
        if not path.is_file():
            failures.append(f"missing artifact: {path}")
            continue
        actual_size = path.stat().st_size
        actual_hash = sha256_file(path)
        if actual_size != artifact.get("bytes"):
            failures.append(f"size mismatch: {path}")
        if actual_hash != artifact.get("sha256"):
            failures.append(f"SHA-256 mismatch: {path}")

    checksum_path = manifest_path.parent / "SHA256SUMS"
    if not checksum_path.is_file():
        failures.append(f"missing evidence checksums: {checksum_path}")
    else:
        checksum_paths: set[str] = set()
        for line in checksum_path.read_text(encoding="utf-8").splitlines():
            try:
                expected, relative_path = line.split("  ", 1)
            except ValueError:
                failures.append(f"malformed checksum line: {line}")
                continue
            checksum_paths.add(relative_path)
            target = manifest_path.parent / relative_path
            if not target.is_file():
                failures.append(f"missing checksummed file: {target}")
            elif sha256_file(target) != expected:
                failures.append(f"evidence hash mismatch: {target}")

        expected_checksum_paths.update(
            str(value)
            for key, value in manifest.get("evidence", {}).items()
            if key != "checksums"
        )
        expected_checksum_paths.add("release-manifest.json")
        missing_checksums = expected_checksum_paths - checksum_paths
        if missing_checksums:
            failures.append(
                "missing checksum entries: " + ", ".join(sorted(missing_checksums))
            )

    for key in ("sbom", "androidNativeInventory", "thirdPartyNotices", "checksums"):
        evidence_name = manifest.get("evidence", {}).get(key)
        if not evidence_name or not (manifest_path.parent / evidence_name).is_file():
            failures.append(f"missing evidence: {key}")
    sbom_path = manifest_path.parent / str(
        manifest.get("evidence", {}).get("sbom", "sbom.cdx.json")
    )
    if sbom_path.is_file():
        try:
            sbom = json.loads(sbom_path.read_text(encoding="utf-8"))
            if sbom.get("bomFormat") != "CycloneDX":
                failures.append("SBOM is not CycloneDX")
            if not isinstance(sbom.get("components"), list) or not sbom["components"]:
                failures.append("SBOM contains no dependency components")
        except (OSError, ValueError) as error:
            failures.append(f"invalid SBOM: {error}")

    notices_path = manifest_path.parent / str(
        manifest.get("evidence", {}).get("thirdPartyNotices", "THIRD_PARTY_NOTICES.txt")
    )
    if notices_path.is_file():
        notices = notices_path.read_text(encoding="utf-8", errors="replace")
        if not notices.startswith("Fractal Forge third-party notices") or "=====" not in notices:
            failures.append("third-party notices contain no package license entries")

    inventory_path = manifest_path.parent / str(
        manifest.get("evidence", {}).get(
            "androidNativeInventory", "ANDROID_NATIVE_INVENTORY.txt"
        )
    )
    if inventory_path.is_file():
        inventory = inventory_path.read_text(encoding="utf-8", errors="replace")
        if not inventory.startswith(
            "Fractal Forge Android/native declaration inventory"
        ) or (
            "=====" not in inventory
            and "No checked-in native dependency declarations found." not in inventory
        ):
            failures.append("Android/native inventory contains no dependency declarations")
    if failures:
        raise ValueError("Release evidence verification failed:\n- " + "\n- ".join(failures))
    if announce:
        print(f"Verified {len(manifest.get('artifacts', []))} release artifact(s)")


def _validate_release_identity(
    manifest: dict[str, Any],
    *,
    expected_version: str,
    expected_build_number: str,
    expected_commit: str,
) -> None:
    expected = {
        "version": expected_version,
        "buildNumber": expected_build_number,
        "commit": expected_commit,
    }
    for field, value in expected.items():
        if str(manifest.get(field)) != value:
            raise ValueError(
                f"release manifest {field} mismatch: {manifest.get(field)!r} != {value!r}"
            )


def _asset_paths_for_manifest(
    manifest_path: Path, manifest: dict[str, Any]
) -> list[Path]:
    artifact_root = manifest_path.parent.parent.resolve()
    assets: list[Path] = []
    for record in manifest["artifacts"]:
        path = Path(record["path"])
        if not path.is_absolute():
            path = manifest_path.parent / path
        path = path.resolve()
        if not path.is_relative_to(artifact_root):
            raise ValueError(f"artifact escapes release directory: {path}")
        assets.append(path)

    assets.append(manifest_path)
    for value in manifest["evidence"].values():
        path = (manifest_path.parent / str(value)).resolve()
        if not path.is_relative_to(manifest_path.parent):
            raise ValueError(f"evidence escapes evidence directory: {path}")
        assets.append(path)
    unique_assets = sorted(set(assets))
    basenames: dict[str, Path] = {}
    for path in unique_assets:
        key = path.name.casefold()
        previous = basenames.get(key)
        if previous is not None and previous != path:
            raise ValueError(
                "duplicate GitHub asset basename: "
                f"{previous.name} ({previous}, {path})"
            )
        basenames[key] = path
    return unique_assets


def verified_asset_paths(
    manifest_path: Path,
    *,
    expected_version: str,
    expected_build_number: str,
    expected_commit: str,
) -> list[Path]:
    manifest_path = manifest_path.resolve()
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    verify(manifest_path, announce=False, manifest=manifest)
    _validate_release_identity(
        manifest,
        expected_version=expected_version,
        expected_build_number=expected_build_number,
        expected_commit=expected_commit,
    )
    return _asset_paths_for_manifest(manifest_path, manifest)


def snapshot_asset_paths(
    manifest_path: Path,
    snapshot_dir: Path,
    *,
    expected_version: str,
    expected_build_number: str,
    expected_commit: str,
) -> list[Path]:
    manifest_path = manifest_path.resolve()
    manifest_bytes = manifest_path.read_bytes()
    manifest = json.loads(manifest_bytes.decode("utf-8"))
    verify(manifest_path, announce=False, manifest=manifest)
    _validate_release_identity(
        manifest,
        expected_version=expected_version,
        expected_build_number=expected_build_number,
        expected_commit=expected_commit,
    )

    snapshot_dir = snapshot_dir.resolve()
    if snapshot_dir.exists():
        if any(snapshot_dir.iterdir()):
            raise ValueError(f"snapshot directory is not empty: {snapshot_dir}")
    else:
        snapshot_dir.mkdir(parents=True, mode=0o700)
    snapshot_evidence = snapshot_dir / "evidence"
    snapshot_evidence.mkdir(mode=0o700)
    snapshot_manifest = snapshot_evidence / manifest_path.name
    snapshot_manifest.write_bytes(manifest_bytes)

    for record in manifest["artifacts"]:
        relative = Path(str(record["path"]))
        source = relative if relative.is_absolute() else manifest_path.parent / relative
        destination = (snapshot_evidence / relative).resolve()
        if not destination.is_relative_to(snapshot_dir):
            raise ValueError(f"snapshot artifact path escapes snapshot: {relative}")
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source.resolve(), destination)

    for value in manifest["evidence"].values():
        relative = Path(str(value))
        source = (manifest_path.parent / relative).resolve()
        destination = (snapshot_evidence / relative).resolve()
        if not destination.is_relative_to(snapshot_evidence):
            raise ValueError(f"snapshot evidence path escapes snapshot: {relative}")
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, destination)

    verify(snapshot_manifest, announce=False, manifest=manifest)
    _validate_release_identity(
        manifest,
        expected_version=expected_version,
        expected_build_number=expected_build_number,
        expected_commit=expected_commit,
    )
    assets = _asset_paths_for_manifest(snapshot_manifest, manifest)
    for path in assets:
        path.chmod(0o400)
    for directory in sorted(
        (path for path in snapshot_dir.rglob("*") if path.is_dir()), reverse=True
    ):
        directory.chmod(0o500)
    snapshot_dir.chmod(0o500)
    return assets


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project-root", default=".")
    parser.add_argument("--artifact", action="append", default=[])
    parser.add_argument(
        "--evidence",
        action="append",
        default=[],
        help="Additional evidence bound as NAME=PATH",
    )
    parser.add_argument("--output-dir", default="release-artifacts/evidence")
    parser.add_argument("--commit")
    parser.add_argument("--version", help="Override the pubspec version for build-time versioning")
    parser.add_argument("--build-number", help="Android build number bound to the artifacts")
    parser.add_argument("--verify", type=Path)
    parser.add_argument("--list-assets", type=Path)
    parser.add_argument("--snapshot-assets", type=Path)
    parser.add_argument("--snapshot-dir", type=Path)
    parser.add_argument("--select-artifacts", type=Path)
    parser.add_argument("--required-artifact", action="append", default=[])
    args = parser.parse_args()
    if (args.list_assets or args.snapshot_assets or args.select_artifacts) and not (
        args.version and args.build_number and args.commit
    ):
        parser.error(
            "asset selection requires --version, --build-number, and --commit"
        )
    if args.snapshot_assets and not args.snapshot_dir:
        parser.error("--snapshot-assets requires --snapshot-dir")
    if args.select_artifacts and not args.required_artifact:
        parser.error("--select-artifacts requires --required-artifact")
    if args.required_artifact and not args.select_artifacts:
        parser.error("--required-artifact requires --select-artifacts")
    if (
        not args.verify
        and not args.list_assets
        and not args.snapshot_assets
        and not args.select_artifacts
        and not args.artifact
    ):
        parser.error(
            "at least one --artifact is required unless --verify or --list-assets is used"
        )
    return args


def main() -> int:
    args = parse_args()
    try:
        if args.snapshot_assets:
            for asset in snapshot_asset_paths(
                args.snapshot_assets,
                args.snapshot_dir,
                expected_version=args.version,
                expected_build_number=args.build_number,
                expected_commit=args.commit,
            ):
                print(asset)
        elif args.select_artifacts:
            for artifact in select_artifacts_for_identity(
                args.select_artifacts,
                version=args.version,
                build_number=args.build_number,
                commit=args.commit,
                required_names=set(args.required_artifact) or None,
            ):
                print(artifact)
        elif args.list_assets:
            for asset in verified_asset_paths(
                args.list_assets,
                expected_version=args.version,
                expected_build_number=args.build_number,
                expected_commit=args.commit,
            ):
                print(asset)
        elif args.verify:
            verify(args.verify)
        else:
            generate(args)
    except (OSError, ValueError) as error:
        print(f"release-evidence: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
