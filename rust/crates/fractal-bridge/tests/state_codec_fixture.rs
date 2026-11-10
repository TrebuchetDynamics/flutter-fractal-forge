use fractal_bridge::api::{StateCommand, StateSession};
use std::{fs, path::Path};

#[test]
fn fixed_high_u64_snapshots_are_detached_or_explicitly_refused() {
    let [modules, parameters, presets, capabilities] =
        ["modules", "parameters", "presets", "capabilities"].map(|name| {
            fs::read_to_string(
                Path::new(env!("CARGO_MANIFEST_DIR"))
                    .join("../../../migration/baseline")
                    .join(format!("{name}.json")),
            )
            .unwrap()
        });
    let session = StateSession::new(
        modules,
        parameters,
        presets,
        capabilities,
        "mandelbrot".into(),
    )
    .unwrap();
    let initial = session.snapshot().unwrap();
    let source = session
        .apply_batch(
            initial.session_id(),
            initial.revision(),
            vec![
                StateCommand::zoom(8.0),
                StateCommand::transparent(true),
                StateCommand::glow_sigma(2.5),
            ],
        )
        .unwrap();
    let result = source.debug_u64_fixtures();
    session.shutdown().unwrap();

    #[cfg(debug_assertions)]
    {
        let fixtures = result.unwrap();
        assert_eq!(fixtures.len(), 2);
        for (fixture, (id, revision)) in fixtures.iter().zip([
            (9_007_199_254_740_993, u64::MAX - 1),
            (u64::MAX - 1, u64::MAX),
        ]) {
            assert_eq!((fixture.session_id(), fixture.revision()), (id, revision));
            assert_eq!(fixture.module_id(), source.module_id());
            assert_eq!(fixture.view().zoom, source.view().zoom);
            assert_eq!(
                fixture.transparent_background(),
                source.transparent_background()
            );
            assert_eq!(fixture.glow_sigma(), source.glow_sigma());
            assert_eq!(fixture.last_adaptive_zoom(), source.last_adaptive_zoom());
            let params = fixture.params();
            let expected = source.params();
            assert_eq!(params.len(), expected.len());
            for (key, value) in params {
                assert_eq!(value.number(), expected[&key].number());
                assert_eq!(value.boolean(), expected[&key].boolean());
                assert_eq!(value.text(), expected[&key].text());
            }
        }
        assert_eq!(source.session_id(), initial.session_id());
        assert_eq!(source.revision(), 1);
        assert_eq!(initial.revision(), 0);
    }
    #[cfg(not(debug_assertions))]
    assert_eq!(
        result.unwrap_err(),
        "High-u64 snapshot fixtures require debug assertions"
    );
}
