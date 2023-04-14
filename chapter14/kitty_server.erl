%%%-------------------------------------------------------------------
%%% @author fluent
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. 3月 2023 16:55
%%%-------------------------------------------------------------------
-module(kitty_server).
-author("fluent").

-export([start_link/0, order_cat/4, return_cat/2, close_shop/1]).
-record(cat, {name, color=green, description}).

%%% 客户api
start_link() -> spawn_link(fun init/0).

%% 同步调用
order_cat(Pid, Name, Color, Description) ->
  Ref = erlang:monitor(process, Pid),
  Pid ! {self(), Ref, {order, Name, Color, Description}},

  receive
    {Ref, Cat} ->
      erlang:demonitor(Ref, [flush]), Cat;
    {'DOWN', Ref, process, Pid, Reason} ->
      erlang:error(Reason)
  after 5000 ->
    erlang:error(timeout)
  end.

%% 这个调用是异步的
return_cat(Pid, Cat = #cat{}) ->
  Pid ! {return, Cat},
  ok.

%% 同步调用
close_shop(Pid) ->
  Ref = erlang:monitor(process, Pid),
  Pid ! {self(), Ref, terminate},
  receive
    {Ref, ok} ->
      erlang:demonitor(Ref, [flush]),
      ok;
    {'DOWN', Ref, process, Pid, Reason} ->
      erlang:error(Reason)
  after 5000 ->
    erlang:error(timeout)
  end.

%%% 服务器函数
init() -> loop([]).

loop(Cats) ->
  receive
    {Pid, Ref, {order, Name, Color, Description}} ->
      io:format("receive order: ~p ~p ~p ~n", [Name, Color, Description]),
      if Cats =:= [] ->
           Pid ! {Ref, make_cat(Name, Color, Description)},
           loop(cats);
         Cats =/= [] ->
           Pid ! {Ref, hd(Cats)}, % hd返回列表头元素
           loop(tl(Cats)) % 删除头元素后的列表
      end;
    {return, Cat = #cat{}} ->
      io:format("receive return: ~p ~n", [Cat]),
      loop([Cat | Cats]);
    {Pid, Ref, terminate} ->
      io:format("terminate ~n"),
      Pid ! {Ref, ok},
      terminate(Cats);
    Unknown ->
      io:format("Unknown msg : ~p ~n", {Unknown}),
      loop(Cats)
  end.

make_cat(Name, Color, Description) ->
  #cat{name = Name, color = Color, description = Description}.

terminate(Cats) ->
  [io:format("~p was set free ~n", [C#cat.name]) || C <- Cats],
  ok.

