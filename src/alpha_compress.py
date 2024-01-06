import re
import os
import json
import logging
from collections import Counter
from datetime import datetime
import configparser

SRC_DIR = os.path.dirname(os.path.abspath(__file__))
MAIN_DIR = os.path.dirname(os.path.abspath(SRC_DIR))
LOG_FILE = os.path.join(MAIN_DIR, "logs/log.txt")

def read_config():
    """
    Initialization of constants, reading from the configuration file.
    """

    config = configparser.ConfigParser()

    global INPUT_FILE
    global OUTPUT_FILE
    global MANUAL_CONFIG_FILE
    global DO_SHORT
    global DO_CONTR

    try:
        config_path = os.path.join(SRC_DIR, "config.ini")
        with open(config_path, 'r', encoding='utf-8') as config_file:
            config.read_file(config_file)

        if 'Configuration' in config:
            INPUT_FILE = os.path.join(MAIN_DIR, config['Configuration'].get('input_file_path', 'work_folder/input.txt'))
            OUTPUT_FILE = os.path.join(MAIN_DIR, config['Configuration'].get('output_file_path', 'work_folder/output.txt'))
            MANUAL_CONFIG_FILE = os.path.join(MAIN_DIR, config['Configuration'].get('manual_json_file_path', 'work_folder/manual_config.json'))
            DO_SHORT = int(config['Configuration'].get('do_shortcuts', '1'))
            DO_CONTR = int(config['Configuration'].get('do_contractions', '1'))

    except FileNotFoundError:
        logging.info("Missing file config.ini. Will continue with default parameters.")
        config['Configuration'] = {
                'input_file_path': 'work_folder/input.txt',
                'output_file_path': 'work_folder/output.txt',
                'manual_json_file_path': 'work_folder/manual_config.json',
                'do_shortcuts': '1',
                'do_contractions': '1'
            }

        with open(os.path.join(SRC_DIR, "config.ini"), 'w', encoding='utf-8') as new_config_file:
            config.write(new_config_file)

        INPUT_FILE = os.path.join(MAIN_DIR, config['Configuration'].get('input_file_path', 'work_folder/input.txt'))
        OUTPUT_FILE = os.path.join(MAIN_DIR, config['Configuration'].get('output_file_path', 'work_folder/output.txt'))
        MANUAL_CONFIG_FILE = os.path.join(MAIN_DIR, config['Configuration'].get('manual_json_file_path', 'work_folder/manual_config.json'))
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
    Replace repeated phrases with shortcuts and log the replacement.

    Args:
        match (re.Match): Regular expression match object.
        phrase_shortcuts (dict): Dictionary storing phrases and shortcuts.

    Returns:
        str: Replaced string.
    """
    phrase = match.group(0)
    shortcut = phrase_shortcuts.get(phrase, phrase)
    if shortcut != phrase:
        logging.info(f"Replacing {phrase} with {shortcut}")
    return shortcut

def shortcut(text):
    """
    Apply shortcuts to the text by replacing repeated two-word phrases with hints and shortcuts.

    Args:
        text (str): Input text.

    Returns:
        text (str): Modified text with shortcuts.
    """
    if DO_SHORT:
        repeated_phrases = find_repeated_phrases(text)

        phrase_shortcuts = {}
        for phrase in repeated_phrases:
            words = phrase.split()
            shortcut = f"{words[0][0]}{words[1][0]}".upper()
            phrase_shortcuts[phrase] = shortcut

        modified_text = re.sub(r'\b(\w+\s\w+)\b', lambda match: replace_repeated_phrases(match, phrase_shortcuts), text)

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
    if DO_SHORT: logging.info("Applying shortcuts")
    modified_text = shortcut(text)

    # Apply contractions
    if DO_CONTR: logging.info("Applying contractions")
    modified_text = contraction(modified_text)

    # Write the modified text to the output file
    with open(output_file, 'w', encoding='utf-8') as file:
        file.write(modified_text)
def write_log():
    """
    Write log data into a log file.
    """

    log_dir = os.path.dirname(LOG_FILE)
    if not os.path.exists(log_dir):
        os.makedirs(log_dir)

    logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s', handlers=[
        logging.FileHandler(LOG_FILE),
        logging.StreamHandler()
    ])

def auto_compressor():
    """
    Automatically compresses text based on configuration from configuration file.
    """

    write_log()

    read_config()

    if not os.path.isfile(INPUT_FILE):
        logging.error(f"Error: Input file '{INPUT_FILE}' not found.")
        exit()

    logging.info("Starting auto compression.")

    compress_text(INPUT_FILE, OUTPUT_FILE)
    logging.info(f"Auto compression completed. Output saved to {OUTPUT_FILE}.")

def manual_compressor():
    """
    Manually compress the text using phrases and shortcuts from a JSON file.
    """

    write_log()

    read_config()

    if not os.path.isfile(INPUT_FILE):
        logging.error(f"Error: Input file '{INPUT_FILE}' not found.")
        exit()
    
    logging.info("Starting manual compression.")

    # Read phrases and shortcuts from the provided JSON file
    with open(MANUAL_CONFIG_FILE, 'r', encoding='utf-8') as json_file:
        try:
            phrase_shortcuts = json.load(json_file)
        except json.JSONDecodeError as e:
            logging.error(f"Error decoding JSON file: {e}")
            exit()

    if not phrase_shortcuts or not isinstance(phrase_shortcuts, dict):
        logging.error("Invalid JSON format. Expected a dictionary of phrases and shortcuts.")
        exit()

    logging.info(f"Reading input from {INPUT_FILE}")
    text = read_file(INPUT_FILE)

    # Apply manual shortcuts
    modified_text = re.sub(r'\b(?:' + '|'.join(map(re.escape, phrase_shortcuts.keys())) + r')\b',
                           lambda match: replace_repeated_phrases(match, phrase_shortcuts),
                           text)

    # Write the modified text to the output file
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as file:
        file.write(modified_text)

    logging.info(f"Manual compression completed. Output saved to {OUTPUT_FILE}.")
