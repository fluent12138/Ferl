%%%-------------------------------------------------------------------
%%% @author fluent
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%% 工作者
%%% @end
%%% Created : 07. 4月 2023 14:22
%%%-------------------------------------------------------------------
-module(ppool_nagger).
-author("fluent").
-behavior(gen_server).

%% API
-export([start_link/4, stop/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, code_change/3, terminate/2]).

start_link(Task, Delay, Max, SendTo) ->
  gen_server:start_link(?MODULE, {Task, Delay, Max, SendTo}, []).

stop(Pid) -> gen_server:call(Pid, stop).

init({Task, Delay, Max, SendTo}) ->
  {ok, {Task, Delay, Max, SendTo}, Delay}.

%%% otp回调函数
handle_call(stop, normal, State) ->
  {stop, normal, ok, State};

handle_call(_Msg, _From, State) -> {noreply, State}.

handle_cast(_Msg, State) -> {noreply, State}.

%% 通过超时的方式发送消息
handle_info(timeout, {Task, Delay, Max, SendTo}) ->
  SendTo ! {self(), Task},
  io:format("send task : ~p ~n", [Task]),
  if Max =:= infinity ->
       {noreply, {Task, Delay, Max, SendTo}, Delay};
     Max =< 1 ->
       {stop, normal, {Task, Delay, 0, SendTo}};
     Max > 1 ->
       {noreply, {Task, Delay, Max - 1, SendTo}, Delay}
  end.

code_change(_OldVsn, State, _Extra) -> {ok, State}.

terminate(_Reason, _State) -> ok.


