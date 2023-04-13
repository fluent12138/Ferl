%%%-------------------------------------------------------------------
%%% @author fluent
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%% 事件服务器
%%% @end
%%% Created : 26. 3月 2023 16:00
%%%-------------------------------------------------------------------
-module(evserv).
-author("fluent").
-include("evserv.hrl").
%% API
-import(event, [start_link/2]).
-export([start/0, start_link/0, terminate/0, subscribe/1, add_event/3, add_event2/3, cancel/1, listen/1, init/0]).

start() ->
  register(?MODULE, Pid = spawn(?MODULE, init, [])),
  Pid.

start_link() ->
  register(?MODULE, Pid = spawn_link(?MODULE, init, [])),
  Pid.

terminate() -> ?MODULE ! shutdown.

subscribe(Pid) ->
  Ref = erlang:monitor(process, whereis(?MODULE)),
  ?MODULE ! {self(), Ref, {subscribe, Pid}},
  receive
    {Ref, ok} -> {ok, Ref};
    {'DOWN', Ref, process, _Pid, Reason} -> {error, Reason}
  after 5000 -> {error, timeout}
  end.
%% add : 转发出错消息
add_event(Name, Description, TimeOut) ->
  Ref = make_ref(),
  ?MODULE ! {self(), Ref, {add, Name, Description, TimeOut}},
  receive
    {Ref, Msg} -> Msg
  after 5000 -> {error, timeout}
  end.
%% add : 关闭客户端进程
add_event2(Name, Description, TimeOut) ->
  Ref = make_ref(),
  ?MODULE ! {self(), Ref, {add, Name, Description, TimeOut}},
  receive
    {Ref, Msg} -> Msg;
    {Ref, {error, Reason}} -> erlang:error(Reason)
  after 5000 -> {error, timeout}
  end.

cancel(Name) ->
  Ref = make_ref(),
  ?MODULE ! {self(), Ref, {cancel, Name}},
  receive
    {Ref, ok} -> ok
  after 5000 -> {error, timeout}
  end.

%% 累计给定时间段收到的所有消息
listen(Delay) ->
  receive
    M = {done, _Name, _Description} -> [M | listen(0)]
  after Delay * 1000 -> []
  end.

init() ->
  %% 从静态文件中加载事件的逻辑可以放在这里
  %% 需要给init 函数传递一个参数，用来指定从哪个文件中寻找事件。然后即可进行加载
  %% 还可以通过这个函数直接把事件传递给服务器
  loop(#state{events = orddict:new(), clients = orddict:new()}).

loop(S = #state{}) ->
  receive
    {Pid, MsgRef, {subscribe, Client}} ->
        %% 获得客户端监视器 -> 添加用户(用户进程Pid) -> 发送消息 -> 更新loop
        Ref = erlang:monitor(process, Client),
        NewClients = orddict:store(Ref, Client, S#state.clients),
        io:format("clients after subscribe : ~p ~n", [NewClients]),
        Pid ! {MsgRef, ok},
        loop(S#state{clients = NewClients});
    {Pid, MsgRef, {add, Name, Description, TimeOut}} ->
      %% 校验超时时间格式 -> 合法 -> 开启进程执行事件 -> 存储事件信息 -> 发送消息 -> 更新loop
      %%                -> 不合法 -> 发送错误事件 -> loop
      case valid_datetime(TimeOut) of
        true ->
          EventPid = event:start_link(Name, TimeOut),
          NewEvents = orddict:store(Name, #event{name = Name,
                                                description = Description,
                                                pid = EventPid,
                                                timeout = TimeOut}, S#state.events),
          io:format("events after add : ~p ~n", [NewEvents]),
          Pid ! {MsgRef, ok},
          loop(S#state{events = NewEvents});
        false ->
          Pid ! {MsgRef, {error, bad_timeout}},
          loop(S)
      end;
    {Pid, MsgRef, {cancel, Name}} ->
      %% 从字典中找到Name事件 -> 存在 -> 取消事件(event:cancel(pid)) -> 删除字典中的事件 -> 发送信息 -> 更新loop
      %%                    -> 不存在, 返回所有事件 -> 发送信息 -> loop
      Events = case orddict:find(Name, S#state.events) of
                 {ok, E} ->
                    event:cancel(E#event.pid),
                    orddict:erase(Name, S#state.events);
                 error -> S#state.events
               end,
      io:format("events after cancel : ~p ~n", [Events]),
      Pid ! {MsgRef, ok},
      loop(S#state{events = Events});
    {done, Name} ->
      case orddict:find(Name, S#state.events) of
        {ok, E} ->
          send_to_clients({done, E#event.name, E#event.description}, S#state.clients),
          NewEvents = orddict:erase(E, S#state.events),
          io:format("events after done: ~p ~n", [NewEvents]),
          loop(S#state{events = NewEvents});
        error ->
          %% 事件取消的同时, 触发了超时
          loop(S)
      end;
    shutdown -> exit(shutdown);
    {'DOWN', Ref, process, _Pid, _Reason} ->
      loop(S#state{clients = orddict:erase(Ref, S#state.clients)});
    code_change -> ?MODULE:loop(S);
    Unknown ->
      io:format("Unknown msg: ~p ~n", [Unknown]),
      loop(S)
  end.

valid_datetime({Date, Time}) ->
  try
    calendar:valid_date(Date) andalso valid_time(Time)
  catch
     error:function_clause -> false
  end;

valid_datetime(_) -> false.

valid_time({H, M, S}) -> valid_time(H, M, S).

valid_time(H, M, S) when H >= 0, H < 24,
                         M >= 0, M < 60,
                         S >= 0, S < 60 -> true;
valid_time(_, _, _) -> false.

send_to_clients(Msg, ClientDict) ->
  orddict:map(fun(_Ref, Pid) -> Pid ! Msg end, ClientDict).

