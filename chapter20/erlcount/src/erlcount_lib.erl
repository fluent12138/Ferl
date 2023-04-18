%%%-------------------------------------------------------------------
%%% @author 勒勒
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. 4月 2023 10:19
%%%-------------------------------------------------------------------
-module(erlcount_lib).
-author("勒勒").
-include_lib("kernel/include/file.hrl").
%% API
-export([find_erl/1, regex_count/2]).

%% 查找所有以.erl结尾的文件
find_erl(Directory) ->
  find_erl(Directory, queue:new()).

%%% 私有函数
%% 基于文件类型进行分派
find_erl(Name, Queue) ->
  {ok, F = #file_info{}} = file:read_file_info(Name),
  case F#file_info.type of
    directory -> handle_directory(Name, Queue);
    regular -> handle_regular_file(Name, Queue);
    _Other -> dequeue_and_run(Queue)
  end.

%% 打开目录, 将其中文件放在队列中
handle_directory(Dir, Queue) ->
  case file:list_dir(Dir) of
    {ok, []} -> dequeue_and_run(Queue);
    {ok, Files} -> dequeue_and_run(enqueue_many(Dir, Files, Queue))
  end.

%% 取出队头, 运行它
dequeue_and_run(Queue) ->
  case queue:out(Queue) of
    {empty, _} -> done;
    {{value, File}, NewQueue} -> find_erl(File, NewQueue)
  end.

%% 把一批文件入队
enqueue_many(Path, Files, Queue) ->
  F = fun(File, Q) -> queue:in(filename:join(Path, File), Q) end, %% filename:join(Path, File)获得完整路径
  lists:foldl(F, Queue, Files).

%% 检查文件是否以.erl结尾
handle_regular_file(Name, Queue) ->
  case filename:extension(Name) of
      ".erl" -> {continue, Name, fun() -> dequeue_and_run(Queue) end};
      _NonErl -> dequeue_and_run(Queue)
  end.

regex_count(Re, Str) ->
  case re:run(Str, Re, [global]) of
    nomatch -> 0;
    {match, List} -> length(List)
  end.