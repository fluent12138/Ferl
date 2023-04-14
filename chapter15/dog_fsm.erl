%%%-------------------------------------------------------------------
%%% @author fluent
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. 3月 2023 13:17
%%%-------------------------------------------------------------------
-module(dog_fsm).
-author("fluent").

%% API
-export([dog_start/0, pet/1, squirrel/1]).

dog_start() ->
  spawn(fun() -> bark() end).

squirrel(Pid) ->
  Pid ! squirrel.

pet(Pid) ->
  Pid ! pet.

bark() ->
  io:format("bark !! ~n"),
  receive
    pet -> wag_tile();
    _ -> bark()
  after 3000 -> bark()
  end.

wag_tile() ->
  io:format("wag_tile ~n"),
  receive
    pet -> sit();
    _ -> wag_tile()
  after 3000 -> bark()
  end.

sit() ->
  io:format("sit ~n"),
  receive
    squirrel -> bark();
    _ -> sit()
  after 3000 -> sit()
  end.
