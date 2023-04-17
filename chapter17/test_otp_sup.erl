%%%-------------------------------------------------------------------
%%% @author fluent
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. 4月 2023 10:59
%%%-------------------------------------------------------------------
-module(test_otp_sup).
-author("fluent").

%% API
-import(musicians, [start_link/2, stop/1]).
-import(band_supervisor, [start_link/1]).
-export([test_musician/0, test_lenient_sup/0, test_angry_sup/0, test_jerk_sup/0, dynamic/0, test_jamband_sup/0]).

test_musician() ->
  io:format("--------start test musician--------~n"),
  I = musicians:start_link(bass, good),
  io:format("~p ~n", [I]),
  timer:sleep(5000),
  musicians:stop(bass),
  io:format("--------finish test musician--------~n ~n"),
  ok.

test_lenient_sup() ->
  io:format("~n--------start test lenient sup--------~n"),
  band_supervisor:start_link(lenient),
  timer:sleep(8000),
  io:format("~n----------function down------------ ~n"),
  ok.

test_angry_sup() ->
  io:format("~n--------start test angry sup--------~n"),
  band_supervisor:start_link(angry),
  timer:sleep(8000),
  io:format("~n----------function down------------ ~n"),
  ok.

test_jerk_sup() ->
  io:format("~n--------start test jerk sup--------~n"),
  band_supervisor:start_link(jerk),
  timer:sleep(5000),
  io:format("~n----------function down------------ ~n"),
  ok.

%% 动态使用标准监督者
dynamic() ->
  io:format("~n--------start test dynamic api--------~n"),
  band_supervisor:start_link(lenient),
  WhichChildren = supervisor:which_children(band_supervisor),
  io:format("which children :  ~p ~n", [WhichChildren]),

  io:format("terminate drum: "),
  supervisor:terminate_child(band_supervisor, drum),

  io:format("terminate singer: "),
  supervisor:terminate_child(band_supervisor, singer),

  io:format("restart singer: "),
  supervisor:restart_child(band_supervisor, singer),

  CountChildren1 = supervisor:count_children(band_supervisor),
  io:format("count children : ~p ~n", [CountChildren1]),

  supervisor:delete_child(band_supervisor, drum),
  io:format("after delete drum ~n"),

  Info = supervisor:restart_child(band_supervisor, drum),
  io:format("restart drum : ~p ~n", [Info]),

  CountChildren2 = supervisor:count_children(band_supervisor),
  io:format("count children : ~p ~n", [CountChildren2]),

  timer:sleep(3000),
  io:format("~n----------function down------------ ~n"),
  ok.

test_jamband_sup() ->
  io:format("~n--------start test jamband sup--------~n"),
  {ok, Pid} = band_supervisor:start_link(jamband),
  supervisor:start_child(Pid, [djembe, good]),
  supervisor:start_child(Pid, [drum, good]),
  ok.
