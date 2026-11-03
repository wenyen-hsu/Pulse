import importlib.util
from pathlib import Path
import unittest
from unittest.mock import patch


spec = importlib.util.spec_from_file_location("changelog", Path(__file__).resolve().parents[1] / "changelog.py")
changelog = importlib.util.module_from_spec(spec)
spec.loader.exec_module(changelog)


class ReleaseNoteIdentityTests(unittest.TestCase):
    def notes(self, markdown):
        with patch.object(changelog, "previous", return_value="1.0.0"):
            return changelog.release_notes("1.1.0", markdown)

    def test_both_installation_languages_use_the_fork_identity(self):
        notes = self.notes("**中文**\n- 中文记录\n\n**English**\n- English entry")
        self.assertEqual(notes.count("**Nokori-1.1.0.dmg**"), 2)
        self.assertEqual(notes.count("**Nokori.app**"), 2)
        self.assertEqual(notes.count(">Nokori 1.1.0</h2>"), 2)
        self.assertIn("https://github.com/wenyen-hsu/Pulse/compare/v1.0.0...v1.1.0", notes)
        self.assertNotIn("Pulse-1.1.0.dmg", notes)
        self.assertNotIn("github.com/qunqin24/Pulse", notes)
        self.assertIn("自动更新", notes)
        self.assertIn("automatic updates are disabled", notes)
        self.assertIn("#cn-pulse-1.1.0", notes)
        self.assertIn("#en-pulse-1.1.0", notes)

    def test_unsectioned_history_keeps_its_text_in_english_furniture(self):
        body = "- **Historical Pulse change.** Original attribution stays."
        notes = self.notes(body)
        self.assertIn(body, notes)
        self.assertIn("Nokori-1.1.0.dmg", notes)
        self.assertNotIn("#cn-pulse", notes)

    def test_first_release_links_to_this_forks_tag(self):
        with patch.object(changelog, "previous", return_value=None):
            notes = changelog.release_notes("1.0.0", "- First entry")
        self.assertIn("https://github.com/wenyen-hsu/Pulse/releases/tag/v1.0.0", notes)
        self.assertNotIn("Already running", notes)

    def test_plain_html_conversion_does_not_rebrand_historical_content(self):
        self.assertEqual(changelog.as_html("Pulse history"), "<p>Pulse history</p>")


if __name__ == "__main__":
    unittest.main()
