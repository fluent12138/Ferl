%%%-------------------------------------------------------------------
%%% @author fluent
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%% 硬件计分板
%%% @end
%%% Created : 05. 4月 2023 8:51
%%%-------------------------------------------------------------------
-module(curling_scoreboard_hw).
-author("fluent").

%% API
-export([set_teams/2, next_round/0, add_point/1, reset_board/0]).

%% 在计分板上显示参赛队伍
set_teams(TeamA, TeamB) ->
  io:format("Scoreboard: Team ~s vs Team ~s ~n", [TeamA, TeamB]).

next_round() ->
  io:format("Scoreboard: round over ~n").

add_point(Team) ->
  io:format("Scoreboard:increased score of team ~s by 1~n", [Team]).

reset_board() ->
  io:format("Scoreboard: All teams are undefined and al1 scores are 0~n").

