# bonk

Ko-Fi webhook api for cardian ocg art orders

## Env variables

- `PORT`: port to listen on
- `DATABASE_URL`: url to connect to database
- `AUTH_TOKEN`: auth token to use for requests

## Quick start

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```

## Deploying to fly.io

```sh
flyctl launch
```
with database 

```sh
flyctl secrets set AUTH_TOKEN=sometoken
```

might also need to set the port

```sh
flyctl secrets set PORT=8080
```