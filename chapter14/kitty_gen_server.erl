%%%-------------------------------------------------------------------
%%% @author fluent
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. 3月 2023 15:05
%%%-------------------------------------------------------------------
-module(kitty_gen_server).
-behavior(gen_server).
-author("fluent").
%% API
-export([start_link/0, order_cat/4, return_cat/2, close_shop/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-record(cat, {name, color=green, description}).

%%% 自定义行为
%%behavior_info(callbacks) -> [{init, 1}, {some_fun, 0}, {other, 3}];
%%behavior_info(_) -> undefined.

start_link() ->
  gen_server:start_link(?MODULE, [], []).

order_cat(Pid, Name, Color, Desc) ->
  gen_server:call(Pid, {order, Name, Color, Desc}, infinity).

return_cat(Pid, Cat = #cat{}) ->
  gen_server:cast(Pid, {return, Cat}).

close_shop(Pid) ->
  gen_server:call(Pid, terminate, infinity).

%%% gen_server 需要的函数
init([]) -> {ok, []}.

handle_call({order, Name, Color, Desc}, _From, Cats) ->
  io:format("handle order ~n"),
  if Cats =:= [] ->
       {reply, make_cat(Name, Color, Desc), Cats};
     Cats =/= [] ->
       {reply, hd(Cats), tl(Cats)}
  end;

handle_call(terminate, _From, Cats) ->
  io:format("termiante ~n"),
  {stop, normal, ok, Cats}.

handle_cast({return, Cat = #cat{}}, Cats) ->
  io:format("handle return ~n"),
  {noreply, [Cat|Cats]}.

handle_info(Msg, Cats) ->
  io:format("unexpect msg : ~p ~n", [Msg]),
  {noreply, Cats}.

terminate(normal, Cats) ->
  [io:format("~p was set free. ~n", [C#cat.name]) || C <- Cats],
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%%私有函数
make_cat(Name, Color, Desc) ->
  #cat{name = Name, color = Color, description = Desc}.
