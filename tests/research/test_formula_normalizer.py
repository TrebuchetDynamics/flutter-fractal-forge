from scripts.research.canonicalize.formula_normalizer import normalize, hash_ast


def test_normalize_deterministic():
    ast = {"iteration_type": "escape_time", "variables": ["z","c"], "update": "z = z**2 + c", "init": "z = 0"}
    assert normalize(ast) == normalize(ast)


def test_normalize_alpha_rename_equivalent():
    ast1 = {"iteration_type": "escape_time", "variables": ["z","c"], "update": "z = z**2 + c", "init": "z = 0"}
    ast2 = {"iteration_type": "escape_time", "variables": ["w","k"], "update": "w = w**2 + k", "init": "w = 0"}
    assert normalize(ast1) == normalize(ast2)


def test_normalize_commutative_sort():
    ast1 = {"iteration_type": "escape_time", "variables": ["z","c"], "update": "z = z**2 + c"}
    ast2 = {"iteration_type": "escape_time", "variables": ["z","c"], "update": "z = c + z**2"}
    assert normalize(ast1) == normalize(ast2)


def test_hash_ast_format():
    ast = {"iteration_type": "escape_time", "variables": ["z","c"], "update": "z = z**2 + c"}
    h = hash_ast(ast)
    assert h.startswith("sha256:")
    assert len(h) == 71


def test_hash_ast_differs_for_different_formulas():
    ast1 = {"iteration_type": "escape_time", "update": "z = z**2 + c"}
    ast2 = {"iteration_type": "escape_time", "update": "z = z**3 + c"}
    assert hash_ast(ast1) != hash_ast(ast2)


def test_normalize_handles_missing_init():
    ast = {"iteration_type": "escape_time", "update": "z = z**2 + c"}
    result = normalize(ast)
    assert isinstance(result, str)


def test_normalize_handles_unparseable_gracefully():
    ast = {"iteration_type": "other", "update": "this is not valid math"}
    # Should not crash; may return a degraded hash
    result = normalize(ast)
    assert isinstance(result, str)
