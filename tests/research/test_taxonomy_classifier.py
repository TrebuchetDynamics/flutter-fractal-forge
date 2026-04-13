from scripts.research.canonicalize.taxonomy_classifier import (
    classify, CATEGORIES, ITERATION_TYPE_MAP
)


def test_all_iteration_types_have_mapping():
    assert set(ITERATION_TYPE_MAP.keys()) >= {
        "escape_time", "newton", "strange_attractor", "ifs", "l_system",
        "raymarch_3d", "cellular", "lyapunov", "tiling",
        "reaction_diffusion", "number_theory", "other",
    }


def test_classify_escape_time_maps_to_category_I():
    r = classify({"iteration_type": "escape_time"})
    assert r["category_roman"] == "I"
    assert r["category_name"] == CATEGORIES["I"]
    assert r["confidence"] == 1.0
    assert r["uncertain"] is False


def test_classify_newton_maps_to_category_II():
    r = classify({"iteration_type": "newton"})
    assert r["category_roman"] == "II"
    assert r["confidence"] == 1.0


def test_classify_other_is_uncertain():
    r = classify({"iteration_type": "other"})
    assert r["category_roman"] == "XIII"
    assert r["uncertain"] is True


def test_classify_missing_iteration_type_falls_back_to_XIII():
    r = classify({})
    assert r["category_roman"] == "XIII"
    assert r["uncertain"] is True


def test_family_detection_mandelbrot():
    ast = {"iteration_type": "escape_time", "update": "z = z**2 + c"}
    r = classify(ast)
    assert r["family"] == "mandelbrot"


def test_family_detection_tricorn():
    ast = {"iteration_type": "escape_time", "update": "z = conj(z)**2 + c"}
    r = classify(ast)
    assert r["family"] == "tricorn"


def test_family_detection_multibrot_cubic():
    ast = {"iteration_type": "escape_time", "update": "z = z**3 + c"}
    r = classify(ast)
    assert r["family"] == "multibrot_cubic"


def test_family_detection_none_for_unrecognized():
    ast = {"iteration_type": "ifs", "update": "x = 0.5*x + 0.5"}
    r = classify(ast)
    assert r["family"] is None


def test_all_19_categories_have_names():
    for roman in ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X",
                  "XI", "XII", "XIII", "XIV", "XV", "XVI", "XVII", "XVIII", "XIX"]:
        assert roman in CATEGORIES
        assert CATEGORIES[roman]  # non-empty
