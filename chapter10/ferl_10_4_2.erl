%%%-------------------------------------------------------------------
%%% @author fluent
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%% 消息发送
%%% @end
%%% Created : 13. 4月 2023 9:55
%%%-------------------------------------------------------------------
-module(ferl_10_4_2).
-author("fluent").

-export([dolphin2/0, dolphin3/0, dolphin1/0, test1/0, test2/0, test3/0]).

dolphin1() ->
  receive
    do_a_flip ->
      io:format("How about no? ~n");
    fish ->
      io:format("So long and thanks for all the fish! ~n");
    _ ->
      io:format("Heh, we're smarter than you humans. ~n")
  end.

dolphin2() ->
  receive
    {From, do_a_flip} ->
      io:format("How about no? ~n"),
      From ! "How about no?";
    {From, fish} ->
      From ! "So long and thanks for all the fish!";
    _ ->
      io:format("Heh, we're smarter than you humans. ~n")
  end.

dolphin3() ->
  receive
    {From, do_a_flip} ->
      From ! "How about no?",
      dolphin3();
    {From, fish} ->
      From ! "So long and thanks for all the fish!";
    _ ->
      io:format("Heh, we're smarter than you humans. ~n"),
      dolphin3()
  end.

mock_receive() ->
  receive
    Msg -> io:format("receive msg from dolphin : ~p ~n", [Msg]), mock_receive()
  after 3000 -> ok
  end.

test1() ->
  Dolphin1 = spawn(?MODULE, dolphin1, []),
  Dolphin1 ! "oh, hello dolphin",
  %% 因为Dolphin1在接收消息后就死亡了, 所以要测试fish需要再创建一个进程
  Dolphin2 = spawn(?MODULE, dolphin1, []),
  Dolphin2 ! fish,
  ok.

test2() ->
  ReceivePid = spawn(fun() -> mock_receive() end),
  Dolphin = spawn(?MODULE, dolphin2, []),
  Dolphin ! {ReceivePid, do_a_flip},
  ok.

test3() ->
  ReceivePid = spawn(fun() -> mock_receive() end),
  Dolphin = spawn(?MODULE, dolphin3, []),
  Dolphin ! {ReceivePid, do_a_flip},
  Dolphin ! {ReceivePid, hh},
  Dolphin ! {ReceivePid, fish},
  ok.