%%%-------------------------------------------------------------------
%%% @author fluent
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 4月 2023 15:27
%%%-------------------------------------------------------------------
-module(test_sup).
-author("fluent").

%% API
-import(sup, [start/2]).
-export([test/0]).
test() ->
    io:format("--------- start sup test ----------- ~n"),
    SupPid = sup:start(evserv, []),
    io:format("start sup : ~p ~n", [SupPid]),
    
    timer:sleep(500), % 延时处理, 如果报错可以提升延迟时间
    DieInfo1 = exit(whereis(evserv), die),
    io:format("die info : ~p ~n", [DieInfo1]),

    timer:sleep(500),
    DieInfo2 = exit(whereis(evserv), die),
    io:format("die info : ~p ~n", [DieInfo2]),
    
    Shutdown = exit(SupPid, shutdown),
    io:format("shutdown sup : ~p ~n", [Shutdown]),
    timer:sleep(500),

    io:format("whereis(evsver) : ~p ~n", [whereis(evserv)]),
    io:format("--------- finish sup test ----------- ~n  ~n"),
    ok.
