#! /bin/bash

erl -make

erl -pa ebin -noshell -s ppool_test test_run -s init stop
erl -pa ebin -noshell -s ppool_test test_sync_queue -s init stop
erl -pa ebin -noshell -s ppool_test test_async_queue -s init stop

rm ./ebin/*.beam
