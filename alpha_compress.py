import re
import os
import logging
from collections import Counter
from datetime import datetime
import configparser

LOG_FILE = "logs/log.txt"

def read_config():

    """
    Initialization of constants, reading from configuration file.
    """

    config = configparser.ConfigParser()

    global INPUT_FILE
    global OUTPUT_FILE
    global AUTO
    global DO_SHORT
    global DO_CONTR

    try:
        with open("config.ini", 'r', encoding='utf-8') as config_file:
            config.read_file(config_file)
        
        if 'Configuration' in config:
            INPUT_FILE = config['Configuration'].get('input_file_path', 'input.txt')
            OUTPUT_FILE = config['Configuration'].get('output_file_path', 'output.txt')
            AUTO = int(config['Configuration'].get('auto', '1'))
            DO_SHORT = int(config['Configuration'].get('do_shortcuts', '1'))
            DO_CONTR = int(config['Configuration'].get('do_contractions', '1'))

    except FileNotFoundError:
        logging.info("Missing file config.ini. Will continue with default parameters.")
        config['Configuration'] = {
                'input_file_path': 'input.txt',
                'output_file_path': 'output.txt',
                'auto': '1',
                'do_shortcuts': '1',
                'do_contractions': '1'
            }

        with open("config.ini", 'w', encoding='utf-8') as new_config_file:
            config.write(new_config_file)

        INPUT_FILE = config['Configuration'].get('input_file_path', 'input.txt')
        OUTPUT_FILE = config['Configuration'].get('output_file_path', 'output.txt')
        AUTO = int(config['Configuration'].get('auto', '1'))
        DO_SHORT = int(config['Configuration'].get('do_shortcuts', '1'))
        DO_CONTR = int(config['Configuration'].get('do_contractions', '1'))
            
def read_file(file_path):
    """
    Read the content of the input file.

    Args:
        file_path (str): Path to the input file.

    Returns:
        str: Content of the file.
    """
    with open(file_path, 'r', encoding='utf-8') as file:
        return file.read()

def find_repeated_phrases(text):
    """
    Find all repeated two-word phrases with more than one occurrence.

    Args:
        text (str): Input text.

    Returns:
        list: List of repeated phrases.
    """
    two_word_phrases = re.findall(r'\b(\w+\s\w+)\b', text)
    return [phrase for phrase, count in Counter(two_word_phrases).items() if count > 1]

def replace_repeated_phrases(match, phrase_shortcuts):
    """
    Replace repeated two-word phrases with shortcuts.

    Args:
        match (re.Match): Regular expression match object.
        phrase_shortcuts (dict): Dictionary storing hints and shortcuts.

    Returns:
        str: Replaced string.
    """
    phrase = match.group(0)
    shortcut = phrase_shortcuts.get(phrase, phrase)
    if shortcut != phrase:
        logging.info(f"Replacing {phrase} with shortcut {shortcut}")
    return shortcut

def shortcut(text):
    """
    Apply shortcuts to the text by replacing repeated two-word phrases with hints and shortcuts.

    Args:
        text (str): Input text.

    Returns:
        str: Modified text with shortcuts.
    """
    if DO_SHORT:
        repeated_phrases = find_repeated_phrases(text)

        phrase_shortcuts = {}
        for phrase in repeated_phrases:
            words = phrase.split()
            shortcut = f"{words[0][0]}{words[1][0]}".upper()
            phrase_shortcuts[phrase] = shortcut

        modified_text = re.sub(r'\b(\w+\s\w+)\b', lambda match: replace_repeated_phrases(match, phrase_shortcuts), text)
        logging.info("Applying shortcuts")
        return modified_text
    else:
        logging.info("Skipping shortcuts.")
        return text


def contraction(text):
    """
    Replace words that can be contracted.

    Args:
        text (str): Input text.

    Returns:
        modified_text (str): Modified text with contractions.
    """
    if DO_CONTR:
        contraction_mapping = {
            " is": "'s",
            " has": "'s",
            " would": "'d",
            " will": "'ll",
            " am": "'m",
            " are": "'re",
            " not": "n't",
            " have": "'ve",
            " had": "'d",
            " cannot": "can't",
            " could not": "couldn't",
            " do not": "don't",
            " does not": "doesn't",
            " did not": "didn't",
            " would not": "wouldn't",
            " will not": "won't",
            " am not": "'m not",
            " are not": "aren't",
            " is not": "isn't",
            " has not": "hasn't",
            " have not": "haven't",
            " had not": "hadn't"
        }

        for old_word, new_word in contraction_mapping.items():
            pattern = r'\b' + re.escape(old_word) + r'\b'
            if re.search(pattern, text):
                text = re.sub(pattern, new_word, text)
                logging.info(f"Contracting {old_word} to {new_word}")

        return text
    else:
        logging.info("Skipping contractions.")
        return text

def compress_text(input_file, output_file):
    """
    Compress the text by applying shortcuts and contractions.

    Args:
        input_file (str): Path to the input file.
        output_file (str): Path to the output file.
    """
    logging.info(f"Reading input from {input_file}")
    text = read_file(input_file)

    # Apply shortcuts
    modified_text = shortcut(text)

    # Apply contractions
    logging.info("Applying contractions")
    modified_text = contraction(modified_text)

    # Write the modified text to the output file
    with open(output_file, 'w', encoding='utf-8') as file:
        file.write(modified_text)
def write_log():
    logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s', handlers=[
        logging.FileHandler(LOG_FILE),
        logging.StreamHandler()
    ])

def auto_compress():
    write_log()

    read_config()

    if not os.path.isfile(INPUT_FILE):
        logging.error(f"Error: Input file '{INPUT_FILE}' not found.")
        exit()

    compress_text(INPUT_FILE, OUTPUT_FILE)
    logging.info(f"Compression completed. Output saved to {OUTPUT_FILE}.")
