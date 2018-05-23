# ExSlack

A Slack Real Time Message API and Web API client for Elixir

## How this works (so far):

### Using Slack Events API

Make your module use `ExSlackEventsApiBot`

```
defmodule MyModule.MyBot do
  use ExSlackEventsApiBot
  ...
end
```

Define your handling events methods:

```
def handle_event(%{"type" => "message"} = event, user_state, bot_state) do
    ...
end
```

Use API Methods in module `ExSlack.WebApi.*` to interact with Slack.

In your controller that receives events from Slack, start your Bot:

```
{ok, pid} = ExSlack.EventsApiBot.start_link(verification_token, team_id, bot_id, bot_access_token, MyModule.MyBot)
```

and process events:

```
ExSlack.EventsApiBot.process_event(pid, params)
```

Look at the Exampe App!

![alt text][under_construction]

## Working on:

* Improving the interface for a WebApiBot
* Defining the basic interface for a RtmApiBot
* Defining modules to interact with different Slack Web API Methods
    * Probably will work on this as needed because there are a lot of Slack API Methdos, contributions are welcome!
* An example web app

A lot of things!

## Contributing

Contributions are going to be very welcome! be patient. You can contact me at `abadon.gutierrez@gmail.com` 

[under_construction]: http://marcellusdrilling.com/wp-content/uploads/2016/10/under-construction.png "Under Construccion"

## Example App

There is an example app of how to use this client here: [https://github.com/abadongutierrez/ExSlackExample]