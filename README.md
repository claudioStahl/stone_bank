# StoneBank

This is a test to Stone, here we can create an account, simulate a transfer and withdrawal, and see a little report.
All values in the app are in cents and integers. So `$10,00` is `1000` in the app.

You can download [postman export](./postman.json) to test the API.
Or you can read [here](#api).

## Install dependencies:

- Elixir >= 1.9.1;
- Erlang >= 21.1.4;
- PostgreSQL >= 11.2;
- Docker >= 19.03.5;
- Docker Compose >= 1.24.1;

## To develop:

- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix ecto.setup`
- Start with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## To test:

- Run `mix test`

## To start with Docker:

- Run `docker-compose up`

This will simulate a production env.

## To deploy:

Fill env vars:

- `WITHOUT_RELEASE` Fill with true if deploy does not use elixir realease feature
- `DATABASE_URL` For example: postgres://user:password@host:5432/database;
- `SECRET_KEY_BASE` You can generate one by calling: mix phx.gen.secret;
- `URL_SCHEME` http or https
- `URL_HOST` Your host
- `URL_PORT` 80 to http and 443 to https

### To deploy at Heroku, follow:

This example will create a app named `stonebank-beta`.

- Create a app with `heroku apps:create stonebank-beta --buildpack hashnuke/elixir --remote beta`;
- Add PostgreSQL addon with `heroku addons:create heroku-postgresql:hobby-dev --app=stonebank-beta`;
- Fill env vars with:
  ```
  heroku config:set WITHOUT_RELEASE=true --app=stonebank-beta
  heroku config:set SECRET_KEY_BASE=$(mix phx.gen.secret) --app=stonebank-beta
  heroku config:set URL_SCHEME=https --app=stonebank-beta
  heroku config:set URL_HOST=stonebank-beta.herokuapp.com --app=stonebank-beta
  heroku config:set URL_PORT=443 --app=stonebank-beta
  ```
- Push app with `git push beta master`
- Migrate the database with `heroku run --app=stonebank-beta -- mix ecto.migrate`
- Restart application `heroku restart --app=stonebank-beta`

Now you can visit [`stonebank-beta.herokuapp.com`](https://stonebank-beta.herokuapp.com) from your browser.

## API

### Create account

POST `https://stone-bank.herokuapp.com/api/v1/accounts`

HEADERS
- Content-Type=application/json

BODY
```
{
  "name": "Claudio Rosseto",
  "password": "123456"
}
```

RESPONSE
```
{
  "data": {
    "id": "54d367ac-6f30-4862-9e60-95618d96a20e",
    "name": "Claudio Rosseto",
    "number": 3,
    "total": 0
  }
}
```

### Login

POST `https://stone-bank.herokuapp.com/api/v1/auth`

HEADERS
- Content-Type=application/json

BODY
```
{
  "number": 1,
  "password": "123456"
}
```

RESPONSE
```
{
  "data": {
    "token": "SFMyNTY.g3QAAAACZAAEZGF0YW0AAAAkNTRkMzY3YWMtNmYzMC00ODYyLTllNjAtOTU2MThkOTZhMjBlZAAGc2lnbmVkbgYAwhcs3G4B.s292NVjt5B9Xbtw71ZQSu319oKdaX3DGN6T2AOkdVYI"
  }
}
```

### Add withdraw

POST `https://stone-bank.herokuapp.com/api/v1/me/withdrawals`

HEADERS
- Content-Type=application/json
- Authorization=Bearer {{stone_bank_token}}

BODY
```
{
  "value": 1000
}
```

RESPONSE
```
{
  "data": {
    "action": "withdrawal",
    "error": null,
    "id": "b162c394-9159-4269-beef-339bb1a6fc3b",
    "inserted_at": "2019-12-06T17:05:26",
    "kind": "outbound",
    "processed_at": null,
    "value": 1000
  }
}
```

### Add transference

POST `https://stone-bank.herokuapp.com/api/v1/me/withdrawals`

HEADERS
- Content-Type=application/json
- Authorization=Bearer {{stone_bank_token}}

BODY
```
{
  "value": 500,
  "destination_account_number": 1
}
```

RESPONSE
```
{
  "data": {
    "action": "transference",
    "error": null,
    "id": "12b2f368-7f55-477c-944b-bfe559ec8c95",
    "inserted_at": "2019-12-06T17:06:25",
    "kind": "outbound",
    "processed_at": null,
    "value": 500
  }
}
```

### General report

GET `https://stone-bank.herokuapp.com/api/v1/backoffice/reporters/general?start=2019-12-01T00:00:01&finish=2020-12-02T00:00:00`

HEADERS
- Content-Type=application/json

RESPONSE
```
{
  "data": {
    "days": [
      {
        "date": "2019-12-05",
        "action": "gift",
        "value": 200000
      }
    ],
    "months": [
      {
        "date": "2019-12-01",
        "action": "gift",
        "value": 300000
      }
    ],
    "total": [
      {
        "action": "gift",
        "value": 300000
      }
    ],
    "years": [
      {
        "date": "2019-01-01",
        "action": "gift",
        "value": 300000
      }
    ]
  }
}
```
