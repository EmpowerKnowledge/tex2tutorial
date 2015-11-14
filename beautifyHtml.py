#! /usr/bin/env python
from bs4 import BeautifulSoup
import re
import sys
import argparse

orig_prettify = BeautifulSoup.prettify
r = re.compile(r'^(\s*)', re.MULTILINE)

def prettify(self, encoding=None, formatter="minimal", indent_width=4):
    return r.sub(r'\1' * indent_width, orig_prettify(self, encoding, formatter))
BeautifulSoup.prettify = prettify


class SmartFormatter(argparse.HelpFormatter):
    """Split the newlines """
    def _split_lines(self, text, width):
        if text.startswith('R|'):
            return text[2:].splitlines()
        return argparse.HelpFormatter._split_lines(self, text, width)


def parse_arguments():
    """ Parse command line arguments
    :return:
        A dictionary with the following:
            - file  the path and filename
    """
    parser = argparse.ArgumentParser(
        description='Only indents an HTML file, it does not does safety checks nor cleanning', formatter_class=SmartFormatter)
    parser.add_argument('--file', '-f', required=True, help='File to prettify')
    args = parser.parse_args()
    return {'file': args.file}


def main():
    args = parse_arguments()
    linestring = open(args['file'], 'r').read()
    soup = BeautifulSoup(linestring,  'html.parser')
    text = soup.prettify("utf-8", indent_width=3)
    text_file = open(args['file'], "wb")
    text_file.write(text)
    text_file.close()


if __name__ == "__main__":
    sys.exit(main())
