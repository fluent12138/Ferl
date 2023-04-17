%%%-------------------------------------------------------------------
%%% @author fluent
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%% 进程池监督者
%%% @end
%%% Created : 07. 4月 2023 9:16
%%%-------------------------------------------------------------------
-module(ppool_sup).
-author("fluent").
-behavior(supervisor).
%% API
-export([start_link/3, init/1]).

start_link(Name, Limit, MFA) ->
  io:format("start ppool_sup...~n"),
  supervisor:start_link(?MODULE, {Name, Limit, MFA}).

init({Name, Limit, MFA}) ->
  io:format("init ppool_sup...~n"),
  MaxRestart = 1,
  MaxTime = 3600,
  {ok, {{one_for_all, MaxRestart, MaxTime},
        [{serv,
          {ppool_serv, start_link, [Name, Limit, self(), MFA]}, % {M, F, A}
          permanent, 5000, worker, [ppool_serv]
        }]
       }}.
