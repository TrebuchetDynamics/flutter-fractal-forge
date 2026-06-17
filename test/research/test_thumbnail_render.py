from pathlib import Path

from scripts.research.admit.thumbnail_render import render, compute_entropy, render_placeholder


def test_render_creates_png(tmp_path):
    out = tmp_path / "thumb.png"
    info = render("f_test", "sha256:abc123", out)
    assert out.exists()
    assert out.stat().st_size > 0
    assert info["placeholder"] is True
    assert info["size"] == [512, 512]


def test_render_different_hashes_produce_different_colors(tmp_path):
    a = tmp_path / "a.png"
    b = tmp_path / "b.png"
    render("f_a", "sha256:aaaaaa", a)
    render("f_b", "sha256:ffffff", b)
    from PIL import Image
    img_a = Image.open(a).getpixel((0, 0))
    img_b = Image.open(b).getpixel((0, 0))
    assert img_a != img_b


def test_compute_entropy_on_solid_color_is_low(tmp_path):
    from PIL import Image
    p = tmp_path / "solid.png"
    img = Image.new("RGB", (64, 64), (128, 128, 128))
    img.save(p)
    e = compute_entropy(p)
    assert e < 1.0


def test_render_returns_quality_dict_shape(tmp_path):
    out = tmp_path / "thumb.png"
    info = render("f_test", "sha256:" + "0" * 64, out)
    assert {"entropy", "checked", "placeholder", "size"} <= set(info.keys())
    assert isinstance(info["entropy"], float)
