#! /bin/bash

erlc *.erl

echo -e "\n------- run kitchen test1 -------"
erl -noshell -s kitchen test1 -s init stop

echo -e "\n------- run kitchen test2 -------"
erl -noshell -s kitchen test2 -s init stop

echo -e "\n------- run kitchen test3 -------"
erl -noshell -s kitchen test3 -s init stop

echo -e "\n------- run multiproc test -------"
erl -noshell -s multiproc test -s init stop
rm *.beam
