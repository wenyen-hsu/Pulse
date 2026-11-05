import json
from pathlib import Path
import re
import shutil
import struct
import subprocess
import tempfile
import unittest
import xml.etree.ElementTree as ET


ROOT = Path(__file__).resolve().parents[2]
SVG_FILES = (
    "AppIcon/nokori-icon.svg",
    "AppIcon/nokori-mark.svg",
    "AppIcon/AppIcon.icon/Assets/mark.svg",
)


class AppIconTests(unittest.TestCase):
    def test_generated_sources_are_current(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory)
            composer = output / "AppIcon/AppIcon.icon"
            (composer / "Assets").mkdir(parents=True)
            shutil.copyfile(ROOT / "AppIcon/AppIcon.icon/icon.json", composer / "icon.json")
            subprocess.run(
                ["swift", str(ROOT / "Scripts/make-app-icon.swift")],
                cwd=output,
                check=True,
                capture_output=True,
                timeout=120,
            )
            for name in (*SVG_FILES, "AppIcon/AppIcon.icon/icon.json"):
                with self.subTest(name=name):
                    self.assertEqual((ROOT / name).read_bytes(), (output / name).read_bytes())

    def test_vectors_are_self_contained_outlined_and_square(self):
        for name in SVG_FILES:
            with self.subTest(name=name):
                source = (ROOT / name).read_text()
                root = ET.fromstring(source)
                self.assertEqual(root.attrib["viewBox"], "0 0 1024 1024")
                self.assertEqual(root.attrib["width"], "1024")
                self.assertEqual(root.attrib["height"], "1024")
                ids = [node.attrib["id"] for node in root.iter() if "id" in node.attrib]
                self.assertEqual(len(ids), len(set(ids)))
                references = re.findall(r"url\(#([^)]+)\)", source)
                self.assertTrue(set(references).issubset(ids))
                for node in root.iter():
                    self.assertNotIn(node.tag.rsplit("}", 1)[-1], ("image", "script", "filter"))
                    self.assertNotIn("stroke", node.attrib)
                    self.assertNotIn("href", node.attrib)

    def test_composer_uses_the_transparent_mark(self):
        self.assertEqual(
            (ROOT / SVG_FILES[1]).read_bytes(), (ROOT / SVG_FILES[2]).read_bytes()
        )
        document = json.loads((ROOT / "AppIcon/AppIcon.icon/icon.json").read_text())
        layers = [layer for group in document["groups"] for layer in group["layers"]]
        self.assertEqual(len(layers), 1)
        self.assertEqual(layers[0]["image-name"], "mark.svg")
        self.assertFalse(layers[0]["glass"])
        self.assertFalse(layers[0]["hidden"])
        self.assertFalse(document["groups"][0]["translucency"]["enabled"])
        self.assertEqual(
            document["fill"]["automatic-gradient"],
            "srgb:0.96471,0.97255,0.98431,1.00000",
        )

    def test_pop_brand_arc_and_no_blue_dot(self):
        for name in SVG_FILES:
            with self.subTest(name=name):
                root = ET.fromstring((ROOT / name).read_text())
                groups = {node.attrib.get("id"): node for node in root.iter()}
                self.assertIn("glass-track", groups)
                self.assertIn("static-brand-arc", groups)
                colors = {node.attrib.get("fill") for node in root.iter()}
                self.assertIn("#FF354F", colors)
                self.assertIn("#FFE23E", colors)
                self.assertIn("#152246", colors)
                self.assertNotIn("#42F2F5", colors)

    def test_png_has_a_1024_pixel_canvas(self):
        data = (ROOT / "AppIcon/nokori-icon-1024.png").read_bytes()
        self.assertEqual(data[:8], b"\x89PNG\r\n\x1a\n")
        self.assertEqual(data[12:16], b"IHDR")
        self.assertEqual(struct.unpack(">II", data[16:24]), (1024, 1024))


if __name__ == "__main__":
    unittest.main()
