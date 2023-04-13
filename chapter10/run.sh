#! /bin/bash

erlc *.erl

echo "------- run ferl_10_4_1 -------"
erl -noshell -s ferl_10_4_1 start -s init stop

echo -e "\n------- run ferl_10_4_2 test1 -------"
erl -noshell -s ferl_10_4_2 test1 -s init stop

echo -e "\n------- run ferl_10_4_2 test2 -------"
erl -noshell -s ferl_10_4_2 test2 -s init stop

echo -e "\n------- run ferl_10_4_2 test3 -------"
erl -noshell -s ferl_10_4_2 test3 -s init stop

rm *.beam
