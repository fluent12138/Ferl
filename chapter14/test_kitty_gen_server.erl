%%%-------------------------------------------------------------------
%%% @author fluent
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. 3月 2023 19:19
%%%-------------------------------------------------------------------
-module(test_kitty_gen_server).
-author("fluent").

%% API
-import(kitty_gen_server, [start_link/0, order_cat/4, return_cat/2, close_shop/1]).
-export([test/0]).


%% kitty_server with gen_server
test() ->
  io:format("----------start test kitty_gen_server----------- ~n"),
  {ok, Pid} = start_link(),
  Cat = order_cat(Pid, "lele", green, "beauty"),
  io:format("order cat : ~p ~n", [Cat]),
  return_cat(Pid, Cat),
  close_shop(Pid),
  io:format("----------finish test kitty_gen_server----------- ~n ~n"),
  ok.
