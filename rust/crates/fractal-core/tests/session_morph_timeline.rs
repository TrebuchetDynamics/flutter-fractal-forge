use fractal_core::{
    catalog_baseline::CatalogBaseline,
    normalization::ViewInput,
    session::{
        Command, MorphTimelineToken, RawParams, RequestGuard, RequestProgress, Session,
        SessionError, Snapshot,
    },
};
use std::sync::Arc;

fn session() -> Session {
    Session::new(
        Arc::new(
            CatalogBaseline::from_jsons(
                include_str!("../../../../migration/baseline/modules.json"),
                include_str!("../../../../migration/baseline/parameters.json"),
                include_str!("../../../../migration/baseline/presets.json"),
                include_str!("../../../../migration/baseline/capabilities.json"),
            )
            .unwrap(),
        ),
        7,
        "mandelbrot",
    )
    .unwrap()
}
fn select(id: &str, reset_view: bool) -> Command {
    Command::SelectModule {
        module_id: id.into(),
        reset_view,
        initial_params: RawParams::new(),
    }
}
fn apply(s: &mut Session, commands: &[Command]) -> Snapshot {
    s.apply_batch(7, s.snapshot().revision(), commands).unwrap()
}
fn tick(s: &mut Session, token: MorphTimelineToken) -> Snapshot {
    s.tick_morph_timeline(7, s.snapshot().revision(), token)
        .unwrap()
}
fn load(id: &str) -> Command {
    Command::Load {
        module_id: Some(id.into()),
        params: RawParams::new(),
        camera: ViewInput {
            zoom: 1.0,
            pan: [0.0; 2],
            rotation: [0.0; 3],
        }
        .into(),
        transparent: false,
    }
}

#[test]
fn source_selection_captures_previous_and_all_36_cubic_callbacks() {
    let mut s = session();
    assert!(!s.snapshot().is_morphing());
    let started = apply(&mut s, &[select("julia", false)]);
    let token = started.morph_timeline_token().unwrap();
    assert_eq!(started.previous_module_id(), Some("mandelbrot"));
    assert_eq!(started.morph_progress(), 0.0);
    for step in 1..=36 {
        let state = tick(&mut s, token);
        assert_eq!(state.revision(), started.revision() + step);
        assert_eq!(
            state.morph_progress(),
            1.0 - (1.0 - step as f64 / 36.0).powi(3)
        );
        assert_eq!(state.is_morphing(), step < 36);
        assert_eq!(
            state.previous_module_id(),
            (step < 36).then_some("mandelbrot")
        );
    }
    let finished = s.snapshot();
    assert_eq!(tick(&mut s, token), finished);
    assert_eq!(started.morph_progress(), 0.0); // Detached, not live metadata.
    assert!(started.is_morphing());
}

#[test]
fn source_no_start_paths_replacement_load_and_explicit_cancel() {
    let mut s = session();
    for reset in [false, true] {
        assert!(!apply(&mut s, &[select("mandelbrot", reset)]).is_morphing());
    }
    let old = apply(&mut s, &[select("julia", false)])
        .morph_timeline_token()
        .unwrap();
    tick(&mut s, old);
    // These source call sites do not cancel the running morph timer.
    for command in [
        select("julia", true),
        Command::ResetView,
        Command::ResetSession,
        Command::ResetParams,
        load("mandelbrot"),
    ] {
        let before = s.snapshot();
        let after = apply(&mut s, &[command]);
        assert_eq!(after.morph_timeline_token(), Some(old));
        assert_eq!(after.morph_progress(), before.morph_progress());
    }
    let before = s.snapshot();
    let no_animation = s
        .apply_batch_with_module_animation(7, before.revision(), &[select("julia", false)], false)
        .unwrap();
    assert_eq!(no_animation.morph_timeline_token(), Some(old));
    let replacement = s
        .apply_batch_with_module_animation(7, no_animation.revision(), &[load("mandelbrot")], true)
        .unwrap();
    let new = replacement.morph_timeline_token().unwrap();
    assert_ne!(old, new);
    assert_eq!(replacement.previous_module_id(), Some("julia"));
    assert_eq!(tick(&mut s, old), replacement);
    assert_eq!(
        s.cancel_morph_timeline(7, replacement.revision(), old)
            .unwrap(),
        replacement
    );
    let cancelled = s
        .cancel_morph_timeline(7, replacement.revision(), new)
        .unwrap();
    assert!(!cancelled.is_morphing());
    assert_eq!(cancelled.morph_progress(), 1.0);
    assert_eq!(cancelled.previous_module_id(), None);
    assert_eq!(tick(&mut s, new), cancelled);
    assert_eq!(
        s.cancel_morph_timeline(7, cancelled.revision(), new)
            .unwrap(),
        cancelled
    );

    // The special wall selection starts no morph, including deferred commit.
    let running = apply(&mut s, &[select("julia", false)])
        .morph_timeline_token()
        .unwrap();
    let request = s
        .begin_number_wall(
            7,
            s.snapshot().revision(),
            &select("number_wall", false),
            RequestGuard::new(true),
            100_000,
        )
        .unwrap()
        .unwrap();
    let partial = tick(&mut s, running);
    loop {
        if let RequestProgress::Finished(status) = s
            .advance_number_wall(7, s.snapshot().revision(), request, 4096)
            .unwrap()
        {
            assert_eq!(
                status,
                fractal_core::number_wall_prime::NumberWallPrimeStatus::VerifiedPrime
            );
            break;
        }
    }
    assert_eq!(s.snapshot().module_id(), "number_wall");
    assert_eq!(s.snapshot().morph_timeline_token(), Some(running));
    assert_eq!(s.snapshot().morph_progress(), partial.morph_progress());
}

#[test]
fn independent_parameter_generations_seeded_targets_and_atomic_rejection() {
    let mut s = session();
    let morph = apply(&mut s, &[select("julia", false)])
        .morph_timeline_token()
        .unwrap();
    let seed = s.randomize_params(7, s.snapshot().revision(), 42).unwrap();
    let param = s
        .start_param_timeline(7, seed.revision(), seed.params().clone())
        .unwrap();
    let partial = tick(&mut s, morph);
    let after_param = s.tick_param_timeline(7, partial.revision(), param).unwrap();
    assert_eq!(after_param.morph_progress(), partial.morph_progress());
    let new_param = s
        .start_param_timeline(7, after_param.revision(), seed.params().clone())
        .unwrap();
    let before = s.snapshot();
    assert_eq!(
        s.tick_param_timeline(7, before.revision(), param).unwrap(),
        before
    );
    assert_eq!(
        s.apply_batch(
            7,
            before.revision(),
            &[
                select("mandelbrot", false),
                Command::Unsupported {
                    operation: "reject".into()
                }
            ]
        ),
        Err(SessionError::UnsupportedOperation("reject".into()))
    );
    assert_eq!(s.snapshot(), before);
    assert_eq!(
        s.tick_morph_timeline(8, before.revision(), morph),
        Err(SessionError::WrongSession)
    );
    assert_eq!(
        s.tick_morph_timeline(7, before.revision() - 1, morph),
        Err(SessionError::StaleRevision)
    );
    let after = tick(&mut s, morph);
    assert_eq!(after.params(), before.params());
    assert!(after.morph_progress() > before.morph_progress());
    assert_eq!(
        s.tick_param_timeline(7, after.revision(), new_param)
            .unwrap()
            .revision(),
        after.revision() + 1
    );
    // Selection cancels parameters but replaces only the morph generation.
    let replaced = apply(&mut s, &[select("mandelbrot", false)]);
    assert_eq!(
        s.tick_param_timeline(7, replaced.revision(), new_param)
            .unwrap(),
        replaced
    );
    assert_eq!(tick(&mut s, morph), replaced);
    assert_ne!(replaced.morph_timeline_token(), Some(morph));
}
