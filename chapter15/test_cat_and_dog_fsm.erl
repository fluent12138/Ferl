-module(test_cat_and_dog_fsm).
-import(cat_fsm, [cat_start/0, event/2]).
-import(dog_fsm, [dog_start/0, squirrel/1, pet/1]).

-export([test_cat_fsm/0, test_dog_fsm/0]).

test_cat_fsm() ->
  io:format("~n------start cat fsm ------ ~n"),
  Pid = cat_fsm:cat_start(),
  Msg = cat_fsm:event(Pid, hh),
  io:format("msg : ~p ~n", [Msg]),
  io:format("------end cat fsm ------ ~n ~n"),
  ok.

test_dog_fsm() ->
  io:format("------start dog fsm ------ ~n"),
  Pid = dog_fsm:dog_start(),
  pet(Pid),
  pet(Pid),
  squirrel(Pid),
  timer:sleep(800),
  io:format("------end dog fsm ------ ~n ~n"),
  ok.
