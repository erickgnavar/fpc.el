#!/usr/bin/env python
# -*- coding: utf-8 -*-
import ast
import csv
import fnmatch
import os
import sys

db = []


class Visitor(ast.NodeVisitor):

    def __init__(self, path=None, *args, **kwargs):
        super(Visitor, self).__init__(*args, **kwargs)
        self._db = []
        self._path = path

    def visit_ClassDef(self, node):
        parents = self._get_parents(node.bases)
        self._db.append({
            'name': '{}({})'.format(node.name, ', '.join(parents)),
            'line': node.lineno,
            'path': self._path
        })

    def _get_parents(self, nodes):
        parents = []
        for node in nodes:
            if isinstance(node, ast.Name):
                parents.append(node.id)
            elif isinstance(node, ast.Attribute):
                parents.append(node.attr)
        return parents

    def get_db(self):
        return self._db


def process_file(path):
    with open(path) as f:
        code = f.read()
        module = ast.parse(code)
        v = Visitor(path=path)
        v.visit(module)
        db.extend(v.get_db())


def process_dir(dir_path):
    for root, dirnames, filenames in os.walk(dir_path):
        for filename in fnmatch.filter(filenames, '*.py'):
            process_file(os.path.join(root, filename))


def write_csv(dir_path):
    csv_path = os.path.join(dir_path, 'fpc.csv')
    with open(csv_path, 'wb') as csv_file:
        writer = csv.writer(csv_file, delimiter=';')
        for item in db:
            writer.writerow(item.values())


if __name__ == '__main__':
    if len(sys.argv) == 2:
        _, path = sys.argv
        if os.path.isdir(path):
            process_dir(path)
        if db:
            write_csv(path)
