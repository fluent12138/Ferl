%%%-------------------------------------------------------------------
%%% @author 勒勒
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. 4月 2023 10:19
%%%-------------------------------------------------------------------
-module(erlcount_sup).
-behavior(supervisor).
-author("勒勒").

%% API
-export([start_link/0, init/1]).

start_link() ->
  supervisor:start_link(?MODULE, []).

init([]) ->
  MaxRestart = 5,
  MaxTime = 10,
  {ok, {{one_for_one, MaxRestart, MaxTime},
        [{dispatch,
          {erlcount_dispatch, start_link, []},
          transient, 60000, worker,
          [erlcount_dispatch]}
        ]}}.
