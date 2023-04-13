#! /bin/bash

erl -make

erl -pa ebin/ -noshell -eval "test_event:test(), test_evserv:test()." -s init stop

erl -pa ebin/ -noshell -eval "test_sup:test()." -s init stop

rm ./ebin/*.beam
