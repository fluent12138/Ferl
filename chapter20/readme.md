## run

```erlang
erl -make
erl -env ERL_LIBS "."
application:load(ppool).
application:start(ppool), application:start(erlcount).
```
