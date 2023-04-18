%%%-------------------------------------------------------------------
%%% @author 勒勒
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. 4月 2023 10:18
%%%-------------------------------------------------------------------
-module(erlcount).
-behavior(application).
-author("勒勒").

%% API
-export([start/2, stop/1]).

start(normal, _Args) ->
  erlcount_sup:start_link().

stop(_State) -> ok.
