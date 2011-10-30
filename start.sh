#!/bin/bash
cd "$( dirname "$0" )"
exec erl -smp disable -pa ebin -s keygen all -s init stop -noshell
