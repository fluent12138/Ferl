%%%-------------------------------------------------------------------
%%% @author fluent
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%% 工作进程监督者
%%% @end
%%% Created : 07. 4月 2023 9:31
%%%-------------------------------------------------------------------
-module(ppool_worker_sup).
-author("fluent").
-behavior(supervisor).
%% API
-export([start_link/1, init/1]).

start_link(MFA = {_, _, _}) ->
  supervisor:start_link(?MODULE, MFA).

init({M, F, A}) ->
  io:format("worker sup init...~n"),

  io:format("MFA : ~p ~n", [{M, F, A}]),
  MaxRestart = 5,
  MaxTime = 3600,
  {ok, {{simple_one_for_one, MaxRestart, MaxTime},
        [{
          ppool_worker, {M, F, A},
          temporary, 5000, worker, [M]
        }]
    }}.