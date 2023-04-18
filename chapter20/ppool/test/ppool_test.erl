%%%-------------------------------------------------------------------
%%% @author 勒勒
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. 4月 2023 14:39
%%%-------------------------------------------------------------------
-module(ppool_test).
-include_lib("eunit/include/eunit.hrl").
-author("勒勒").
%% API
-import(ppool, [start/2, start_pool/3, run/2, sync_queue/2, async_queue/2]).
-export([find_unique_name/0, test_find_unique_name/0]).
-export([test_run/0, test_sync_queue/0, test_async_queue/0]).

start() ->
  application:start(ppool_app),
  start_pool(nagger, 2, {ppool_nagger, start_link, []}),
  timer:sleep(1000),
  ok.

find_unique_name() ->
  application:start(ppool_app),
  Name = list_to_atom(lists:flatten(io_lib:format("~p", [erlang:timestamp()]))),
  case whereis(Name) of
    undefined -> Name;
    _ -> find_unique_name()
  end.

test_find_unique_name() ->
  Name1 = find_unique_name(),
  Name2 = find_unique_name(),
  ?assertNotEqual(Name1, Name2).

%% 测试同步不入队
test_run() ->
  start(),
  io:format("-------------------start test_run ------------------- ~n"),
  run(nagger, ["finish the chapter!", 1000, 5, self()]),
  run(nagger, ["Watch a good movie!", 1000, 5, self()]),
  Noalloc = run(nagger, ["Playing game!", 1000, 5, self()]),
  io:format("~p ~n", [Noalloc]),
  timer:sleep(7000),
  io:format("-------------------finished------------------- ~n"),
  ok.

%% 测试同步入队
test_sync_queue() ->
  start(),
  io:format("-------------------start test_sync_queue ------------------- ~n"),
  sync_queue(nagger, ["finish the chapter!", 1000, 5, self()]),
  sync_queue(nagger, ["Watch a good movie!", 1000, 5, self()]),
  sync_queue(nagger, ["Playing game!", 1000, 5, self()]),
  timer:sleep(12000),
  io:format("-------------------finished------------------- ~n"),
  ok.

%% 测试异步入队
test_async_queue() ->
  start(),
  io:format("-------------------start test_async_queue ------------------- ~n"),
  async_queue(nagger, ["finish the chapter!", 1000, 5, self()]),
  async_queue(nagger, ["Watch a good movie!", 1000, 5, self()]),
  async_queue(nagger, ["Playing game!", 1000, 5, self()]),
  timer:sleep(12000),
  io:format("-------------------finished------------------- ~n"),
  ok.