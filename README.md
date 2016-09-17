# fpc.el Find python class

Find python class and see results using helm

This package use python AST for inspect the project files and generate a db

## Dependencies

- `f.el`
- `projectile`
- `helm`

## Installation

Clone this repo into `load-path` and `(require 'fpc)`

## Usage

For search a class use `fpc-find-class`

For rebuild the classes db use `fpc-rebuild-db`


## TODO

- [ ] Find another location for `fpc.csv` and avoid use the project directory.
- [ ] Update `fpc.csv` when update of delete python files
