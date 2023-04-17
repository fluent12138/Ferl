#! /bin/bash

erlc *.erl

erl -noshell -s test_otp_sup test_musician -s init stop

erl -noshell -s test_otp_sup test_lenient_sup -s init stop

erl -noshell -s test_otp_sup test_angry_sup -s init stop

erl -noshell -s test_otp_sup test_jerk_sup -s init stop

erl -noshell -s test_otp_sup dynamic -s init stop

erl -noshell -s test_otp_sup test_jamband_sup -s init stop

rm *.beam
