%%%-------------------------------------------------------------------
%%% @author fluent
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. 3月 2023 14:35
%%%-------------------------------------------------------------------
-module(test_evserv).
-author("fluent").
-import(evserv, [start/0, start_link/0, terminate/0, listen/1, init/0, subscribe/1, cancel/1, add_event/3, add_event2/3]).
%% API
-export([test/0]).

test() ->
  io:format("--------- start evserv test -----------~n"),
  evserv:start(),
  evserv:subscribe(self()),
  evserv:add_event("ahh", "test", {{2023, 4, 26}, {20, 13, 30}}),
  evserv:add_event("ahhh", "test", {{2023, 4, 26}, {20, 13, 30}}),
  evserv:listen(3),
  evserv:cancel("ahh"),
  evserv:add_event("ahh", "test", {{2023, 4, 26}, {20, 13, 30}}),
  io:format("--------- start evserv test -----------~n~n"),
  ok.








