%%%-------------------------------------------------------------------
%%% @author 勒勒
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. 4月 2023 10:18
%%%-------------------------------------------------------------------
-module(erlcount_counter).
-author("勒勒").
-behavior(gen_server).
-record(state, {dispatcher, ref, file, re}).
%% API
-export([start_link/4, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

start_link(Dispatcher, Ref, FileName, Regex) ->
  gen_server:start_link(?MODULE, [Dispatcher, Ref, FileName, Regex], []).

init([Dispatcher, Ref, FileName, Regex]) ->
  self() ! start,
  {ok, #state{dispatcher = Dispatcher, ref = Ref, file = FileName, re = Regex}}.

handle_call(_Msg, _Name, State) ->
  {noreply, State}.

handle_cast(_Msg, State) ->
  {noreply, State}.

handle_info(start, S = #state{re = Re, ref = Ref}) ->
  {ok, Bin} = file:read_file(S#state.file),
  Count = erlcount_lib:regex_count(Re, Bin),
  erlcount_dispatch:complete(S#state.dispatcher, Re, Ref, Count),
  {stop, normal, S}.

terminate(_Reason, _State) -> ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.



















