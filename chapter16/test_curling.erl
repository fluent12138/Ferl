%%%-------------------------------------------------------------------
%%% @author fluent
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. 4月 2023 9:10
%%%-------------------------------------------------------------------
-module(test_curling).
-author("fluent").
%% API
-import(curling_scoreboard, [init/1]).
-import(curling, [start_link/2, add_points/3, next_round/1]).
-export([test/0]).

test() ->
  %% 实现协议暴露给了所有人
  io:format("-------version 1.0-------~n"),
  {ok, Pid} = gen_event:start_link(),
  io:format("start link : ~p ~n", [Pid]),
  gen_event:add_handler(Pid, curling_scoreboard, []),
  gen_event:notify(Pid, {set_teams, "A", "B"}),
  gen_event:notify(Pid, {add_points, "A", 3}),
  gen_event:notify(Pid, next_round),
  gen_event:delete_handler(Pid, curling_scoreboard, turn_off),
  gen_event:notify(Pid, next_round),

  io:format("~n-------version 2.0-------~n"),
  %% 封装后
  {ok, Pid2} = curling:start_link("A", "B"),
  io:format("start link : ~p ~n", [Pid2]),
  %% 新闻需要知道冰壶比赛的信息
  HandlerId = curling:join_feed(Pid2, self()),
  io:format("handler id : ~p ~n", [HandlerId]),
  curling:add_points(Pid2, "A", 3),
  curling:add_points(Pid2, "B", 3),
  curling:leave_feed(Pid2, HandlerId),
  curling:next_round(Pid2),
  curling:add_points(Pid2, "A", 3),
  curling:next_round(Pid2),

  GameInfo = curling:game_info(Pid2),
  io:format("game info : ~p ~n", [GameInfo]),
  ok.


