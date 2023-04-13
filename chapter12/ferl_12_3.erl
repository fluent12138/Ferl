%%%-------------------------------------------------------------------
%%% @author fluent
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%% 命名进程
%%% @end
%%% Created : 13. 4月 2023 14:03
%%%-------------------------------------------------------------------
-module(ferl_12_3).
-author("fluent").

%% API
-export([critic1/0, critic2/0, restarter/0, test1/0, test2/0, judge2/2]).

start_critic() ->
  spawn(?MODULE, critic1, []).

%% 普通版本
judge1(Pid, Band, Album) ->
  Pid ! {self(), {Band, Album}},
  receive
    {Pid, Criticism} -> io:format("criticism : ~p ~n", [Criticism])
  after 2000 -> io:format("timeout ~n")
  end.

critic1() ->
  receive
    {From, {"Rage Against the Turing Machine", "Unit Testify"}} ->
      From ! {self(), "They are great!"};
    {From, {"System of a Downtime", "Memoize"}} ->
      From ! {self(), "They're not Johnny Crash but they're good."};
    {From, {"Johnny Crash", "The Token Ring of Fire"}} ->
      From ! {self(), "Simply incredible"};
    {From, {_Band, _Album}} ->
      From ! {self(), "They are terrible!"}
  end,
  critic1().

%% 通过监控器重启
start_critic2() ->
  spawn(?MODULE, restarter, []).

restarter() ->
  process_flag(trap_exit, true),
  Pid = spawn_link(?MODULE, critic2, []),
  register(critic, Pid),
  receive
    {'EXIT', Pid, normal} -> ok;
    {'EXIT', Pid, shutdown} -> ok;
    {'EXIT', Pid, _} ->
      restarter()
  end.

judge2(Band, Album) ->
  Ref = make_ref(),
  critic ! {self(), Ref, {Band, Album}},
  receive
    {Ref, Criticism} -> io:format("criticism : ~p ~n", [Criticism])
  after 2000 -> io:format("timeout ~n")
  end.

critic2() ->
  receive
    {From, Ref, {"Rage Against the Turing Machine", "Unit Testify"}} ->
      From ! {Ref, "They are great!"};
    {From, Ref, {"System of a Downtime", "Memoize"}} ->
      From ! {Ref, "They're not Johnny Crash but they're good."};
    {From, Ref, {"Johnny Crash", "The Token Ring of Fire"}} ->
      From ! {Ref, "Simply incredible"};
    {From, Ref, {_Band, _Album}} ->
      From ! {Ref, "They are terrible!"}
  end,
  critic2().

%% 无监控版本
test1() ->
  Pid = start_critic(),
  judge1(Pid, "Genesic", "The Lambda Lies Down on Broadway"),
  exit(Pid, kill),
  judge1(Pid, "Rage Against the Turing Machine", "Unit Testify"),
  ok.

%% 有监控可重启版本
test2() ->
  start_critic2(),
  timer:sleep(800), %% 等待register完成
  judge2("Genesic", "The Lambda Lies Down on Broadway"),
  exit(whereis(critic), kill),
  timer:sleep(800), %% 等待register完成
  judge2("Rage Against the Turing Machine", "Unit Testify"),
  ok.















