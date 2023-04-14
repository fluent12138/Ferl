#! /bin/bash

erlc *.erl

erl -noshell -s test_kitty_server test -s init stop

erl -noshell -s test_kitty_server2 test -s init stop

erl -noshell -s test_kitty_gen_server test -s init stop

rm *.beam
