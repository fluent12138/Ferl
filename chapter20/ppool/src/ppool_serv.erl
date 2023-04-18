%%%-------------------------------------------------------------------
%%% @author 勒勒
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. 4月 2023 9:46
%%%-------------------------------------------------------------------
-module(ppool_serv).
-author("勒勒").
-behavior(gen_server).
-define(SPEC(MFA), {worker_sup,
                    {ppool_worker_sup, start_link, [MFA]},
                    permanent, 10000, supervisor, [ppool_worker_sup]
                   }).
-record(state, {limit = 0, sup, refs, queue = queue:new()}). % refs为监控器的引用
%% API
-export([start/4, start_link/4, run/2, sync_queue/2, async_queue/2, stop/1]).
-export([init/1, handle_info/2, handle_call/3, handle_cast/2, code_change/3, terminate/2]).

start(Name, Limit, Sup, MFA) when is_atom(Name), is_integer(Limit) ->
  gen_server:start({local, Name}, ?MODULE, {Limit, MFA, Sup}, []).

start_link(Name, Limit, Sup, MFA) when is_atom(Name), is_integer(Limit) ->
  io:format("start ppool_serv ~p ... ~n ", [Name]),
  gen_server:start_link({local, Name}, ?MODULE, {Limit, MFA, Sup}, []).

run(Name, Args) ->
  io:format("test start run ~n"),
  gen_server:call(Name, {run, Args}).

sync_queue(Name, Args) ->
  gen_server:call(Name, {sync, Args}, infinity).

async_queue(Name, Args) ->
  gen_server:cast(Name, {async, Args}).

stop(Name) ->
  gen_server:call(Name, stop).

init({Limit, MFA, Sup}) ->
  %% 注释部分会造成死锁!
  %% 在ppool_sup中需要启动serv, 等待init信息返回, 而init中使用start_child需要等待ppool_sup返回
  %% {ok, Pid} = supervisor:start_child(Sup, ?SPEC(MFA)),
  io:format("init ppool_serv...~n"),
  self() ! {start_worker_supervisor, Sup, MFA},
  {ok, #state{limit = Limit, refs = gb_sets:empty()}}.

%% 获取任务结束信息
handle_info({'DOWN', Ref, process, _Pid,  _}, S = #state{refs = Refs}) ->
  io:format("received down msg, bool : ~p ~n", [gb_sets:is_element(Ref, Refs)]),
  case gb_sets:is_element(Ref, Refs) of
    true -> handle_down_worker(Ref, S);
    false -> {noreply, S}
  end;

handle_info({start_worker_supervisor, Sup, MFA}, S = #state{}) ->
  io:format("start worker...~n"),
  {ok, Pid} = supervisor:start_child(Sup, ?SPEC(MFA)),
  io:format("start worker pid : ~p ~n", [Pid]),
  {noreply, S#state{sup = Pid}};

handle_info(Msg, State) ->
  io:format("UnKnown msg : ~p ~n", [Msg]),
  {noreply, State}.

%% 处理结束任务
handle_down_worker(Ref, S = #state{limit = L, sup = Sup, refs = Refs}) ->
  case queue:out(S#state.queue) of
    {{value, {From, Args}}, Q} -> % 处理同步
      {ok, Pid} = supervisor:start_child(Sup, Args),
      NewRef = erlang:monitor(process, Pid),
      NewRefs = gb_sets:insert(NewRef, gb_sets:delete(Ref, Refs)), %为什么是insert 而不是add
      gen_server:reply(From, {ok, Pid}),
      {noreply, S#state{refs = NewRefs, queue = Q}};
    {{value, Args}, Q} -> % 处理异步
      {ok, Pid} = supervisor:start_child(Sup, Args),
      NewRef = erlang:monitor(process, Pid),
      NewRefs = gb_sets:insert(NewRef, gb_sets:delete(Ref, Refs)),
      {noreply, S#state{refs = NewRefs, queue = Q}};
    {empty, _} ->
      {noreply, S#state{limit = L + 1, refs = gb_sets:delete(Ref, Refs)}}
  end.

%% run
handle_call({run, Args}, _From, S = #state{limit = N, sup = Sup, refs = R}) when N > 0 ->
  io:format("args : ~p, limit : ~p, sup : ~p, refs : ~p ~n", [Args, N, Sup, R]),
  {ok, Pid} = supervisor:start_child(Sup, Args),
  Ref = erlang:monitor(process, Pid),
  {reply, {ok, Pid}, S#state{limit = N - 1, refs = gb_sets:add(Ref, R)}};

handle_call({run, _Args}, _From, S = #state{limit = N}) when N =< 0 ->
  {reply, noalloc, S};

%% sync_queue
handle_call({sync, Args}, _From, S = #state{limit = N, sup = Sup, refs = R}) when N > 0 ->
  {ok, Pid} = supervisor:start_child(Sup, Args),
  Ref = erlang:monitor(process, Pid),
  {reply, {ok, Pid}, S#state{limit = N - 1, refs = gb_sets:add(Ref, R)}};

handle_call({sync, Args}, From, S = #state{queue = Q}) ->
  {noreply, S#state{queue = queue:in({From, Args}, Q)}};

%% stop & 未知消息
handle_call(stop, _From, State) -> {stop, normal, ok, State};

handle_call(_Msg, _From, State) -> {noreply, State}.

%% async_queue
handle_cast({async, Args}, S = #state{limit = N, sup = Sup, refs =  R}) when N > 0 ->
  {ok, Pid} = supervisor:start_child(Sup, Args),
  Ref = erlang:monitor(process, Pid),
  {noreply, S#state{limit = N - 1, refs = gb_sets:add(Ref, R)}};

handle_cast({async, Args}, S = #state{limit = N, queue = Q}) when N =< 0 ->
  {noreply, S#state{queue = queue:in(Args, Q)}};

handle_cast(_Msg, State) -> {noreply, State}.

code_change(_OldVsn, State, _Extra) -> {ok, State}.

terminate(_Reason, _State) -> ok.