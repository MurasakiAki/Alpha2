import unittest
import tempfile
import shutil
import os
import sys

sys.path.append(os.path.join(os.path.dirname(__file__), '..'))

from src.alpha_compress import find_repeated_phrases

class TestTextCompression(unittest.TestCase):

    def setUp(self):
        self.test_dir = tempfile.mkdtemp()

    def tearDown(self):
        shutil.rmtree(self.test_dir)

    def create_test_file(self, content):
        test_file_path = os.path.join(self.test_dir, 'test_input.txt')
        with open(test_file_path, 'w', encoding='utf-8') as test_file:
            test_file.write(content)
        return test_file_path

    def test_find_repeated_phrases(self):
        text1 = "This is a sample text without repeated phrases."
        result1 = find_repeated_phrases(text1)
        self.assertEqual(result1, [])

        text2 = "This is a test. This is a test."
        result2 = find_repeated_phrases(text2)
        self.assertEqual(result2, ['This is'])

        text3 = "Hello world. Hello world. This is a test. This is a test."
        result3 = find_repeated_phrases(text3)
        self.assertEqual(result3, ['Hello world', 'This is'])

if __name__ == '__main__':
    unittest.main()
