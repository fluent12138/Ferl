%%%-------------------------------------------------------------------
%%% @author fluent
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. 4月 2023 9:03
%%%-------------------------------------------------------------------
-module(curling_scoreboard).
-author("fluent").
-import(curling_scoreboard_hw, [set_teams/2, add_point/1, reset_board/1, next_round/0]).
%% API
-export([init/1, handle_event/2, handle_call/2, handle_info/2]).

init([]) -> {ok, []}.

handle_event({set_teams, TeamA, TeamB}, State) ->
  io:format("set teams"),
  curling_scoreboard_hw:set_teams(TeamA, TeamB),
  {ok, State};

handle_event({add_points, Team, N}, State) ->
  [curling_scoreboard_hw:add_point(Team) || _ <- lists:seq(1, N)],
  {ok, State};

handle_event(next_round, State) ->
  curling_scoreboard_hw:next_round(),
  {ok, State};

handle_event(_, State) -> {ok, State}.

handle_call(_, State) -> {ok, ok, State}.

handle_info(_, State) -> {ok, State}.

