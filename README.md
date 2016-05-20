# rl_discord_bot

Discord bot for Rocket League stats using RLTracker.pro written in ruby

You can either host it yourself or [add a running instance](https://discordapp.com/oauth2/authorize?client_id=180125930981687297&scope=bot&permissions=0) to your Discord.

## Run

Requires the environment variables `RLTRACKER_API_KEY`, `DISCORD_TOKEN`, `DISCORD_APP_ID` to be set.

```shell
./bot.rb
```

or as a daemon:

```shell
./daemon.rb start
```