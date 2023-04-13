#! /bin/bash

erlc *.erl

echo -e "\n------- run ferl_12_3 test1 -------"
erl -noshell -s ferl_12_3 test1 -s init stop

echo -e "\n------- run ferl_12_3 test2 -------"
erl -noshell -s ferl_12_3 test2 -s init stop

rm *.beam
