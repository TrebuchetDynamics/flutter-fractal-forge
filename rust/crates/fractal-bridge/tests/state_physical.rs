use fractal_bridge::api::*;

fn session() -> StateSession {
    let s = StateSession::new(
        include_str!("../../../../migration/baseline/modules.json").into(),
        include_str!("../../../../migration/baseline/parameters.json").into(),
        include_str!("../../../../migration/baseline/presets.json").into(),
        include_str!("../../../../migration/baseline/capabilities.json").into(),
        "mandelbrot".into(),
    )
    .unwrap();
    let id = s.snapshot().unwrap().session_id();
    s.apply_batch(
        id,
        0,
        vec![StateCommand::zoom(10.0), StateCommand::pan(0.0, 0.0)],
    )
    .unwrap();
    s
}
fn close(a: StateView, zoom: f64, pan: [f64; 2]) {
    for (a, b) in [a.zoom, a.pan_x, a.pan_y, a.rot_x, a.rot_y, a.rot_z]
        .into_iter()
        .zip([zoom, pan[0], pan[1], 0.0, 0.0, 0.0])
    {
        assert!((a - b).abs() < 1e-8, "{a} != {b}");
    }
}
fn apply(s: &StateSession, events: Vec<StatePhysicalEvent>) -> StatePhysicalResult {
    let snap = s.snapshot().unwrap();
    s.apply_physical_async(
        snap.session_id(),
        snap.revision(),
        Some(StateViewport {
            width: 300.0,
            height: 240.0,
        }),
        events,
    )
    .unwrap()
}
fn e(seq: u64, input: StatePhysicalInput) -> StatePhysicalEvent {
    StatePhysicalEvent::new(seq, None, false, input)
}
fn pointer(seq: u64, id: u64, x: f64, phase: StatePointerPhase, source: i64) -> StatePhysicalEvent {
    StatePhysicalEvent::new(
        seq,
        Some(source),
        false,
        StatePhysicalInput::pointer(
            id,
            x,
            100.0,
            phase,
            StatePointerKind::Touch,
            if phase == StatePointerPhase::Down || phase == StatePointerPhase::Move {
                1
            } else {
                0
            },
        ),
    )
}
// Exact raw prefix of physical-events.json double-interruption/new-input, seq 0..8.
fn in_flight(s: &StateSession) {
    use StatePointerPhase::*;
    apply(
        s,
        vec![
            e(0, StatePhysicalInput::wall(0)),
            pointer(1, 1, 100.0, Down, 16000),
            pointer(2, 1, 100.0, Up, 32000),
        ],
    );
    apply(
        s,
        vec![
            e(
                3,
                StatePhysicalInput::pump(s.physical_generation().unwrap(), 400000),
            ),
            e(4, StatePhysicalInput::wall(10000)),
            pointer(5, 2, 100.0, Down, 48000),
            pointer(6, 2, 100.0, Up, 64000),
        ],
    );
    apply(
        s,
        vec![
            e(
                7,
                StatePhysicalInput::pump(s.physical_generation().unwrap(), 0),
            ),
            e(
                8,
                StatePhysicalInput::pump(s.physical_generation().unwrap(), 50000),
            ),
        ],
    );
}

#[test]
fn supported_raw_oracle_inputs_and_ordered_results_through_typed_constructors() {
    // Frozen wheel/mandelbrot seq 0 and 2; then a repeated wheel in one publication.
    let s = session();
    let before = s.snapshot().unwrap();
    let wheel = |seq, dy| {
        StatePhysicalEvent::new(
            seq,
            Some(12345),
            false,
            StatePhysicalInput::wheel(200.0, 90.0, dy),
        )
    };
    let result = apply(&s, vec![wheel(0, -200.0)]);
    close(
        result.snapshot().view(),
        12.214027581601698,
        [0.003776442644208712, -0.0022658655865252265],
    );
    let result = apply(&s, vec![wheel(2, 200.0), wheel(4, -200.0)]);
    assert_eq!(result.snapshot().revision(), before.revision() + 2);
    assert_eq!(result.interactions(), vec![StateInteraction::Correction; 2]);
    close(
        result.snapshot().view(),
        12.214027581601698,
        [0.003776442644208712, -0.0022658655865252265],
    );
    assert_eq!(result.generation(), s.physical_generation().unwrap());

    // Frozen double-interruption/new-input seq 9/12/18 camera checkpoints.
    let s = session();
    in_flight(&s);
    close(
        s.snapshot().unwrap().view(),
        15.99159558415413,
        [-0.007805656874345826, -0.00312226274973833],
    );
    let result = apply(
        &s,
        vec![
            pointer(10, 3, 140.0, StatePointerPhase::Down, 80000),
            pointer(11, 3, 190.0, StatePointerPhase::Move, 96000),
        ],
    );
    assert_eq!(result.interactions(), vec![StateInteraction::Start]);
    close(
        result.snapshot().view(),
        15.99159558415413,
        [-0.020833333333333336, -0.00312226274973833],
    );
    let released = apply(
        &s,
        vec![
            e(13, StatePhysicalInput::pump(result.generation(), 500000)),
            pointer(15, 3, 190.0, StatePointerPhase::Cancel, 112000),
        ],
    );
    let generation = s.physical_generation().unwrap();
    let result = apply(
        &s,
        vec![
            e(16, StatePhysicalInput::pump(generation, 0)),
            e(17, StatePhysicalInput::pump(generation, 2100000)),
        ],
    );
    assert_eq!(released.interactions(), vec![StateInteraction::End]);
    assert!(result.interactions().is_empty());
    close(
        result.snapshot().view(),
        15.99159558415413,
        [-0.020833333333333336, -0.00312226274973833],
    );

    // Canvas/control/none routing, all key phases and key variants, exact ordering.
    let mut events = vec![e(20, StatePhysicalInput::focus(StateFocus::Canvas))];
    let mut expected = Vec::new();
    let mut seq = 21;
    for key in [
        StateKey::Left,
        StateKey::Right,
        StateKey::Up,
        StateKey::Down,
        StateKey::Plus,
        StateKey::Minus,
        StateKey::Reset,
        StateKey::Unknown,
    ] {
        for phase in [
            StateKeyPhase::Down,
            StateKeyPhase::Repeat,
            StateKeyPhase::Up,
        ] {
            events.push(e(seq, StatePhysicalInput::key(key, phase)));
            seq += 1;
            expected.push(
                if phase == StateKeyPhase::Down && key != StateKey::Unknown {
                    StateKeyDisposition::Handled
                } else {
                    StateKeyDisposition::Ignored
                },
            );
        }
    }
    events.extend([
        e(seq, StatePhysicalInput::focus(StateFocus::Control)),
        e(
            seq + 1,
            StatePhysicalInput::key(StateKey::Left, StateKeyPhase::Down),
        ),
        e(seq + 2, StatePhysicalInput::focus(StateFocus::None)),
        e(
            seq + 3,
            StatePhysicalInput::key(StateKey::Left, StateKeyPhase::Down),
        ),
    ]);
    expected.extend([
        StateKeyDisposition::ControlHandled,
        StateKeyDisposition::Ignored,
    ]);
    let result = apply(&s, events);
    assert_eq!(result.keys(), expected);
    close(result.snapshot().view(), 1.0, [0.0, 0.0]);
    // Consumed routing must not inspect invalid geometry or invent a callback.
    let result = apply(
        &s,
        vec![StatePhysicalEvent::new(
            100,
            None,
            true,
            StatePhysicalInput::wheel(f64::NAN, 0.0, f64::NAN),
        )],
    );
    assert!(result.interactions().is_empty());
    close(result.snapshot().view(), 1.0, [0.0, 0.0]);
}

#[test]
fn rejected_batches_and_abandoned_pumps_are_atomic_and_detached() {
    let s = session();
    let control = session();
    in_flight(&s);
    in_flight(&control);
    let before = s.snapshot().unwrap();
    let generation = s.physical_generation().unwrap();
    let pump = || {
        StatePhysicalEvent::new(
            9,
            Some(i64::MIN),
            false,
            StatePhysicalInput::pump(generation, 10000),
        )
    };
    assert!(
        s.apply_physical_async(
            before.session_id() + 1,
            before.revision(),
            None,
            vec![pump()]
        )
        .is_err()
    );
    assert!(
        s.apply_physical_async(before.session_id(), 0, None, vec![pump()])
            .is_err()
    );
    for invalid in [
        e(10, StatePhysicalInput::pump(generation, -1)),
        e(9, StatePhysicalInput::wall(0)),
        e(10, StatePhysicalInput::pump(generation, i64::MAX)),
        e(10, StatePhysicalInput::wheel(f64::NAN, 0.0, 1.0)),
    ] {
        assert!(
            s.apply_physical_async(
                before.session_id(),
                before.revision(),
                None,
                vec![pump(), invalid]
            )
            .is_err()
        );
        assert_eq!(s.snapshot().unwrap().revision(), before.revision());
        assert_eq!(s.physical_generation().unwrap(), generation);
        close(
            s.snapshot().unwrap().view(),
            before.view().zoom,
            [before.view().pan_x, before.view().pan_y],
        );
    }
    let result = apply(&s, vec![pump()]);
    let expected = apply(&control, vec![pump()]);
    close(
        result.snapshot().view(),
        expected.snapshot().view().zoom,
        [
            expected.snapshot().view().pan_x,
            expected.snapshot().view().pan_y,
        ],
    );
    assert_eq!(result.interactions(), expected.interactions());
    apply(
        &s,
        vec![
            pointer(10, 3, 140.0, StatePointerPhase::Down, 80000),
            pointer(11, 3, 190.0, StatePointerPhase::Move, 96000),
        ],
    );
    assert_ne!(generation, s.physical_generation().unwrap());
    let old = s.snapshot().unwrap();
    let stale = apply(
        &s,
        vec![e(20, StatePhysicalInput::pump(generation, 500000))],
    );
    close(
        stale.snapshot().view(),
        old.view().zoom,
        [old.view().pan_x, old.view().pan_y],
    );
    assert!(stale.interactions().is_empty());
    assert_eq!(stale.snapshot().revision(), old.revision() + 1);
    let snap = s.snapshot().unwrap();
    assert_eq!(
        s.apply_physical_async(snap.session_id(), snap.revision(), None, vec![])
            .unwrap()
            .snapshot()
            .revision(),
        snap.revision()
    );
    // Full-width ID/buttons/sequence and signed times cross the public constructors.
    // Cancel the prior pointer before exercising the full-width pointer identity.
    apply(
        &s,
        vec![pointer(21, 3, 190.0, StatePointerPhase::Cancel, 112000)],
    );
    for (offset, kind, phase) in [
        (0, StatePointerKind::Mouse, StatePointerPhase::Down),
        (1, StatePointerKind::Stylus, StatePointerPhase::Cancel),
    ] {
        apply(
            &s,
            vec![StatePhysicalEvent::new(
                u64::MAX - 3 + offset,
                Some(i64::MIN),
                false,
                StatePhysicalInput::pointer(u64::MAX, 0.0, 0.0, phase, kind, u64::MAX),
            )],
        );
    }
    apply(
        &s,
        vec![
            StatePhysicalEvent::new(
                u64::MAX - 1,
                Some(i64::MAX),
                false,
                StatePhysicalInput::wall(i64::MIN),
            ),
            e(u64::MAX, StatePhysicalInput::dispose_input()),
        ],
    );
    assert!(
        s.apply_physical_async(
            snap.session_id(),
            s.snapshot().unwrap().revision(),
            None,
            vec![pump()]
        )
        .is_err()
    );
    let retained = result.snapshot();
    let retained_interactions = result.interactions();
    s.shutdown().unwrap();
    assert!(s.physical_generation().is_err());
    assert_eq!(result.snapshot().revision(), retained.revision());
    close(
        result.snapshot().view(),
        retained.view().zoom,
        [retained.view().pan_x, retained.view().pan_y],
    );
    assert_eq!(result.generation(), expected.generation());
    assert_eq!(result.keys(), expected.keys());
    assert_eq!(result.interactions(), retained_interactions);
}
