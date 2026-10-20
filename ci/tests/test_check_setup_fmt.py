"""Exercise the comparison script without network access or CMake execution."""

from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "ci" / "check-setup-fmt.sh"
GOLDEN = ROOT / "cmake" / "GOLD_setup_fmt.cmake"


class CheckSetupFmtTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix="setup fmt check ")
        self.addCleanup(self.directory.cleanup)
        self.candidate = Path(self.directory.name) / "setup_fmt.cmake"
        self.candidate.write_bytes(GOLDEN.read_bytes())

    def check(self, golden=GOLDEN):
        return subprocess.run(
            ["bash", str(SCRIPT), str(golden), str(self.candidate)],
            capture_output=True,
            text=True,
            check=False,
        )

    def test_identical_copy_passes(self):
        result = self.check()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("matches the golden copy", result.stdout)

    def test_drift_fails_and_prints_diff(self):
        self.candidate.write_bytes(GOLDEN.read_bytes() + b"# unexpected drift\n")
        result = self.check()
        self.assertEqual(result.returncode, 1)
        self.assertIn("differs from the golden copy", result.stderr)
        self.assertIn("+# unexpected drift", result.stdout)

    def test_whitespace_drift_fails(self):
        self.candidate.write_bytes(GOLDEN.read_bytes().replace(b"\n", b"\r\n"))
        self.assertEqual(self.check().returncode, 1)

    def test_missing_candidate_fails(self):
        self.candidate.unlink()
        result = self.check()
        self.assertEqual(result.returncode, 1)
        self.assertIn("missing or unreadable", result.stderr)

    def test_missing_golden_fails(self):
        result = self.check(Path(self.directory.name) / "missing-golden.cmake")
        self.assertEqual(result.returncode, 1)
        self.assertIn("missing or unreadable", result.stderr)


if __name__ == "__main__":
    unittest.main()
