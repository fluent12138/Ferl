%%%-------------------------------------------------------------------
%%% @author fluent
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 4月 2023 10:55
%%%-------------------------------------------------------------------
-module(kitchen).
-author("fluent").

%% API
-export([fridge1/0, fridge2/1, test1/0, test2/0, test3/0]).

start(FoodList) ->
  spawn(?MODULE, fridge2, [FoodList]).

%% 假装存放了东西, 其实什么都没有做的函数
fridge1() ->
  receive
    {From, {store, _Food}} ->
      From ! {self(), ok},
      fridge1();
    {From, {take, _Food}} ->
      From ! {self(), not_found},
      fridge1();
    terminate -> ok
  end.

%% 通过递归存储信息
fridge2(FoodList) ->
  receive
    {From, {store, Food}} ->
      From ! {self(), {ok, Food}},
      fridge2([Food | FoodList]);
    {From, {take, Food}} ->
      case lists:member(Food, FoodList) of
        true ->
          From ! {self(), {ok, Food}},
          fridge2(lists:delete(Food, FoodList));
        false ->
          From ! {self(), not_found},
          fridge2(FoodList)
      end;
    terminate -> ok
  end.

store(Pid, Food) ->
  Pid ! {self(), {store, Food}},
  receive
    {Pid, Msg} -> io:format("receive msg store: ~p ~n", [Msg])
  end.

take(Pid, Food) ->
  Pid ! {self(), {take, Food}},
  receive
    {Pid, Msg} -> io:format("receive msg take: ~p ~n", [Msg])
  end.

%% 处理超时
store2(Pid, Food) ->
  Pid ! {self(), {store, Food}},
  receive
    {Pid, Msg} -> io:format("receive msg store: ~p ~n", [Msg])
  after 3000 -> io:format("timeout ~n")
  end.

take2(Pid, Food) ->
  Pid ! {self(), {take, Food}},
  receive
    {Pid, Msg} -> io:format("receive msg take: ~p ~n", [Msg])
  after 3000 -> io:format("timeout ~n")
  end.

test1() ->
  Pid = spawn(?MODULE, fridge2, [[baking_soda]]),
  store(Pid, milk),
  store(Pid, bacon),
  take(Pid, bacon),
  take(Pid, turkey),
  ok.

test2() ->
  Pid = start([rhubarb, dog, hotdog]),
  take(Pid, dog),
  take(Pid, dog),
  ok.

test3() ->
  Pid = spawn(fun() -> ok end),
  timer:sleep(1000), %% 模拟进程死亡, Pid不存在
  store2(Pid, dog),
  take2(Pid, dog),
  ok.
