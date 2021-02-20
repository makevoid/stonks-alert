# stonks-alert

Stock alerts SMS app

### Features

- simple, ~ 200 LoC program
- stock prices feed from alphavantage
- twilio SMS alerts

### Price feed details

You don't need a Pro account if you're ok with some delay (prices being checked once every ~10m)

### Twilio accounts alerts setup

- Twilio account
- A number registered with SMS capabilities
- API keys configured

### Env vars / secrets file

This app can be configured with environment variables and secret files, note env vars take precedence.

#### `SMS_RECIPIENTS` / `~/.stonks_sms_recipients`

pipe separated list of numbers receiving the sms, if you want just one number just use the number, no spaces with international prefix e.g. `+4412345678`

#### `ALPHA_VANTAGE_KEY` / `~/.alphavantage-stonks-key`

alphavantage api key

#### `TWILIO_NUMBER` / `~/.twilio_number`

twilio number you registered (see prereqs.)

#### `TWILIO_KEYS` / `~/.twilio_keys`

twilio credentials, pipe separated - `TWILIO_SID|TWILIO_TOKEN` - e.g. `AC12762bf81fca007e3a6399bce2886932|fb5456bfc88774839f2d4d74bdf48817`


---

hope this helps :)

have fun!

@makevoid
