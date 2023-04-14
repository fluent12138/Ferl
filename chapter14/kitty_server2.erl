%%%-------------------------------------------------------------------
%%% @author fluent
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. 3月 2023 16:55
%%%-------------------------------------------------------------------
-module(kitty_server2).
-author("fluent").

-export([start_link/0, order_cat/4, return_cat/2, close_shop/1]).
-export([handle_call/3, handle_cast/2, init/1]).
-record(cat, {name, color=green, description}).
-import(my_server, [start_link/2, call/2, cast/2, reply/2]).

%%% 客户api
start_link() -> my_server:start_link(?MODULE, []).

%% 同步调用
order_cat(Pid, Name, Color, Description) ->
  my_server:call(Pid, {order, Name, Color, Description}).

%% 异步调用
return_cat(Pid, Cat = #cat{}) ->
  my_server:cast(Pid, {return, Cat}).

%% 同步调用
close_shop(Pid) ->
  my_server:call(Pid, terminate).

%%% 服务器函数
init([]) -> [].

%% 处理订单
handle_call({order, Name, Color, Description}, From, Cats) ->
  if Cats =:=  [] ->
      my_server:reply(From, make_cat(Name, Color, Description)),
      Cats;
    Cats =/= [] ->
      my_server:reply(From, hd(Cats)),
      tl(Cats)
  end;

%% 处理关闭
handle_call(terminate, From, Cats) ->
  my_server:reply(From, ok),
  terminate(Cats).

%% 处理退出, 异步
handle_cast({return, Cat = #cat{}}, Cats) -> [Cat | Cats].

%%% 私有函数
make_cat(Name, Color, Description) ->
  #cat{name = Name, color = Color, description = Description}.

terminate(Cats) ->
  [io:format("~p was set free ~n", [C#cat.name]) || C <- Cats],
  exit(normal).

