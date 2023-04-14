#! /bin/bash

erlc *.erl

erl -noshell -s test_curling test -s init stop

rm *.beam
