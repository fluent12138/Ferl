%%%-------------------------------------------------------------------
%%% @author fluent
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%% ppool顶层监督者
%%% @end
%%% Created : 07. 4月 2023 8:48
%%%-------------------------------------------------------------------
-module(ppool_supersup).
-author("fluent").
-behavior(supervisor).
%% API
-export([start_link/0, start_pool/3, stop_pool/1]).
-export([init/1]).

start_link() ->
  io:format("start supersup ...~n"),
  supervisor:start_link({local, ppool}, ?MODULE, []). %{local, Name} 命名

init([]) ->
  MaxRestart = 6,
  MaxTime = 3000,
  {ok, {{one_for_one, MaxRestart, MaxTime}, []}}.

%% Limit : 工作者进程个数; MFA元组 : 工作者进程监督者启动工作者进程需要的{M, F, A}元组
start_pool(Name, Limit, MFA) ->
  io:format("start pool ... args: {~p, ~p, ~p}~n", [Name, Limit, MFA]),
  ChildSpec = {Name,
               {ppool_sup, start_link, [Name, Limit, MFA]}, % {M, F, A}
               permanent, 10500, supervisor, [ppool_sup]
              },
  supervisor:start_child(ppool, ChildSpec).

stop_pool(Name) ->
  supervisor:terminate_child(ppool, Name),
  supervisor:delete_child(ppool, Name).


