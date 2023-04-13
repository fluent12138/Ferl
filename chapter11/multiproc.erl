%%%-------------------------------------------------------------------
%%% @author fluent
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 4月 2023 11:38
%%%-------------------------------------------------------------------
-module(multiproc).
-author("fluent").

%% API
-export([test/0]).

important() ->
  receive
    {Priority, Message} when Priority > 10 ->
      [Message | important()]
  after 0 -> normal()
  end.

normal() ->
  receive
    {_, Message} ->
      [Message | normal()]
  after 0 -> []
  end.

test() ->
  self() ! {7, low}, self() ! {15, high}, self() ! {1, low}, self() ! {17, high},
  SortedList = important(),
  io:format("~p ~n", [SortedList]),
  ok.
