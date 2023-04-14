%%%-------------------------------------------------------------------
%%% @author fluent
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. 4月 2023 10:52
%%%-------------------------------------------------------------------
-module(curling_feed).
-author("fluent").
-behavior(gen_event).
%% API
-export([init/1, handle_event/2, handle_call/2, handle_info/2, code_change/3, terminate/2]).

init([Pid]) -> {ok, Pid}.

handle_event(Event, Pid) ->
  Pid ! {curling_feed, Event},
  {ok, Pid}.

handle_call(_, State) -> {ok, ok, State}.

handle_info(_, State) -> {ok, State}.

code_change(_OldVsn, State, _Extra) -> {ok, State}.

terminate(_Reason, _State) -> ok.

