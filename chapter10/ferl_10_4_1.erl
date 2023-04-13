%%%-------------------------------------------------------------------
%%% @author fluent
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%% 创建进程
%%% @end
%%% Created : 13. 4月 2023 9:43
%%%-------------------------------------------------------------------
-module(ferl_10_4_1).
-author("fluent").

%% API
-export([start/0]).

start() ->
  F = fun() -> 2 + 2 end,
  Pid1 = spawn(F),
  io:format("Pid : ~p ~n", [Pid1]),

  Pid2 = spawn(fun() -> io:format("~p ~n", [2 + 2]) end),
  io:format("Pid : ~p ~n", [Pid2]),

  G = fun(X) -> timer:sleep(10), io:format("~p ~n", [X]) end,
  Pids = [spawn(fun() -> G(X) end) || X <- lists:seq(1, 10)],
  io:format("Pids : ~p ~n", [Pids]),

  io:format("self : ~p ~n", [self()]),
  ok.