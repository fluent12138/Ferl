%%%-------------------------------------------------------------------
%%% @author fluent
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. 4月 2023 9:43
%%%-------------------------------------------------------------------
-module(curling).
-author("fluent").
%% API
-export([start_link/2, add_points/3, next_round/1, join_feed/2, leave_feed/2, game_info/1]).

start_link(TeamA, TeamB) ->
  {ok, Pid} = gen_event:start_link(),
  %% 记分板
  gen_event:add_handler(Pid, curling_scoreboard, []),
  %% 启动比赛状态累加器
  gen_event:add_handler(Pid, curling_accumulator, []),
  set_teams(Pid, TeamA, TeamB),
  {ok, Pid}.

set_teams(Pid, TeamA, TeamB) ->
  gen_event:notify(Pid, {set_teams, TeamA, TeamB}).

add_points(Pid, Team, N) ->
  gen_event:notify(Pid, {add_points, Team, N}).

next_round(Pid) -> gen_event:notify(Pid, next_round).

%% 为进程ToPid订阅比赛消息
join_feed(Pid, ToPid) ->
  HandlerId = {curling_feed, make_ref()},
  gen_event:add_handler(Pid, HandlerId, [ToPid]),
  HandlerId.

leave_feed(Pid, HandlerId) ->
  gen_event:delete_handler(Pid, HandlerId, leave_feed).

%% 返回当前比赛状态, 为迟到订阅的提供
game_info(Pid) ->
  gen_event:call(Pid, curling_accumulator, game_data).
