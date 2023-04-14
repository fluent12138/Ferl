%%%-------------------------------------------------------------------
%%% @author fluent
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. 3月 2023 19:35
%%%-------------------------------------------------------------------
-module(my_server).
-author("fluent").

%% API
-export([call/2, start/2, start_link/2, cast/2, reply/2]).

%% 公共API
start(Module,InitialState) ->
  spawn(fun() -> init(Module, InitialState) end).

start_link(Module,InitialState) ->
  spawn_link(fun() -> init(Module, InitialState) end).

call(Pid, Msg) ->
  Ref = erlang:monitor(process, Pid),
  Pid ! {sync, self(), Ref, Msg}, % 区分同步异步
  receive
    {Ref, Reply} ->
      erlang:demonitor(Ref, [flush]),
      Reply;
    {'DOWN', Ref, process, Pid, Reason} ->
      erlang:error(Reason)
  after 5000 ->
    erlang:error(timeout)
  end.

cast(Pid, Msg) ->
  Pid ! {async, Msg},
  ok.

%% Pid是当前函数的call
reply({Pid, Ref}, Reply) ->
  Pid ! {Ref, Reply}.

%%% 私有函数
init(Module, InitialState) ->
  loop(Module, Module:init(InitialState)).

loop(Module, State) ->
  receive
    {async, Msg} ->
      io:format("async, Msg : ~p ~n", [Msg]),
      loop(Module, Module:handle_cast(Msg, State));
    {sync, Pid, Ref, Msg} ->
      io:format("sync, Msg : ~p ~n", [Msg]),
      loop(Module, Module:handle_call(Msg, {Pid, Ref}, State)) % 通过{Pid, Ref}一个变量抽象, 不需要知道引用的信息
  end.

