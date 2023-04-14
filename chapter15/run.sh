#! /bin/bash

erlc *.erl

erl -noshell -s test_cat_and_dog_fsm test_cat_fsm -s init stop

erl -noshell -s test_cat_and_dog_fsm test_dog_fsm -s init stop

erl -noshell -s test_trade_fsm start -s init stop

rm *.beam
