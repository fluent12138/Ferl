%%%-------------------------------------------------------------------
%%% @author fluent
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 4月 2023 15:27
%%%-------------------------------------------------------------------
-module(test_event).
-author("fluent").

%% API
-import(event, [start/2, cancel/1]).
-export([test/0]).
test() ->
    io:format("--------- start event test ----------- ~n"),
    Pid1 = event:start("test_event", calendar:local_time()),
    io:format("Pid : ~p ~n", [Pid1]),

    Pid2 = event:start("test_event", {{2023,4,13}, {15,32,05}}),
    event:cancel(Pid2),
    io:format("--------- finish event test ----------- ~n  ~n"),
    ok.
