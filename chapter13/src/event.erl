%%%-------------------------------------------------------------------
%%% @author fluent
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. 3月 2023 14:27
%%%-------------------------------------------------------------------
-module(event).
-author("fluent").
%% API
-export([start/2, cancel/1, loop/1, init/3, normalize/1, start_link/2]).
-include("event.hrl").

start(EventName, Delay) ->
  spawn(?MODULE, init, [self(), EventName, Delay]).

start_link(EventName, Delay) ->
  spawn_link(?MODULE, init, [self(), EventName, Delay]).

%%% 事件模块的内部实现
init(Server, EventName, Delay) ->
  loop(#state{server = Server, name = EventName, to_go = time_to_go(Delay)}).

loop(S = #state{server = Server, to_go = [T|Next]}) ->
  receive
    %% cancel event
    {Server, Ref, cancel} -> Server ! {Ref, ok}, io:format("receive cancel event~n")
  after T * 1000 ->
    if Next =:= [] ->
        Server ! {done, S#state.name}, io:format("after : ~p ~n", [{done, S#state.name}]);
       Next =/= [] ->
        loop(S#state{to_go = Next}) %加长延时时间
    end
  end.

%% 打破时间限制, erlang timeout最大为50 days
normalize(N) ->
  Limit = 49 * 24 * 60 * 60,
  [N rem Limit| lists:duplicate(N div Limit, Limit)].

%% 格式化, {{Year, Month, Day}, {Hour, Minute, Second}} -> Seconds
time_to_go(TimeOut = {{_, _, _}, {_, _, _}}) ->
  Now = calendar:local_time(),
  ToGo = calendar:datetime_to_gregorian_seconds(TimeOut) - calendar:datetime_to_gregorian_seconds(Now),
  Secs = if ToGo > 0 -> ToGo;
            ToGo =< 0 -> 0
         end,
  normalize(Secs).

cancel(Pid) ->
  %% 设置监视器, 以免进程死亡
  Ref = erlang:monitor(process, Pid),
  Pid ! {self(), Ref, cancel},
  receive
    {Ref, ok} ->
      erlang:demonitor(Ref, [flush]),
      io:format("evenything is fine ~n");
    {'DOWN', Ref, process, pid, _Reason} ->
      io:format("pid : ~p had down ~n", [Pid]),
      ok
  end.
