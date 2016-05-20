#!/usr/bin/env ruby
require "discordrb"
require "open-uri"

rltracker_api_key = ENV["RLTRACKER_API_KEY"]
token = ENV["DISCORD_TOKEN"]
app_id = ENV["DISCORD_APP_ID"]

bot = Discordrb::Commands::CommandBot.new token: token, application_id: app_id, prefix: "!"

bot.mention do |event|
  event.user.pm("Stop mentioning me!")
end

bot.command [:help] do |event, key|
  if key && key.downcase == "rltracker.pro"
    help
  else
    "\"!help rltracker.pro\" is a comment tho"
  end
end

def help
  "!stats {platform} {user_id} {white}

  Platform:
    steam/pc/ps4/xbox

  user_id:
    Steam = Use your vanityurl or steamID64 | https://steamid.io.
    PS4 = Use your ps4 username
    XBOX = Use your xbox username
    NOTICE:
      If you got Spaces in your Name, replace all spaces with it with %20
  white
    For everybody using the white theme ( Just add it after your normal call)

  Examples:
    !stats steam yixn
    !stats steam yixn white
    !stats ps4 Mr%20Narwha1
    !stats xbox rafro white
  Other Commands:
    !stat {platform} {user_id} {white}
    !stat help == !help rltracker.pro
    !stat dev
    !stat github
    !stat originators
  "
end

bot.command [:rank, :ranks] do |event|
  "Please use !stats instead of rank. We are not some kind of second class Tool!"
end

bot.command [:stats, :stat] do |event, platform, user_id, negated|
  (platform = platform.downcase) if platform
  unless platform == "steam" || platform == "originators" || platform == "pc" || platform == "sites" || platform == "ps4" ||  platform == "xbox" || platform == "help" || platform == "github"|| platform == "dev"
    "Please dont forget to use Platform(steam/pc/ps4/xbox).\nFor more help please use !help rltracker.pro"
  else
    if user_id == nil
      case platform
        when "dev"
          "Quent#6782 did the concept of the Bot and Yixn#9503 redeveloped it."
        when "sites"
          "Featured by http://rltracker.pro partnered with http://prorl.com"
        when "originators"
          "Featured by http://rltracker.pro partnered with http://prorl.com"
        when "help"
          help
        when "github"
          "https://github.com/rltracker/rl_discord_bot"
        else
          "Please include an UserID like:\n!stat steam yixn.\nFor more help please use !help rltracker.pro"
      end
    else
      case platform
        when "steam"
          platform = 1
        when "pc"
          platform = 1
        when "ps4"
          platform = 2
        when "xbox"
          platform = 3
      end
      if user_id == "Harley" || user_id == "Steamierpilot72"
        "ProspectScrub"
      else
        if user_id.downcase == "quent"
          user_id = "kuxir97"
        end
        url = URI.parse("http://rltracker.pro/api/profile/get?api_key=#{rltracker_api_key}&platform=#{platform}&id=#{user_id}")
        req = Net::HTTP::Get.new(url.to_s)
        res = Net::HTTP.start(url.host, url.port) do |http|
          http.request(req)
        end
        response = JSON.parse(res.body)
        if negated == "white"
          image = response["image_negated"]
        else
          image = response["image"]
        end
        if image == nil
          case platform
            when 1
              "Cant find Player. Please use your vanityurl or steamID64\nIf you are not sure about which id to use, please refer to https://steamid.io.\nFor more help please use !help rltracker.pro"
            when 2
              "Cant find Player. Please use your ps4 username.\nFor more help please use !help rltracker.pro"
            when 3
              "Cant find Player. Please use your xbox username.\nFor more help please use !help rltracker.pro"
          end
        else
          file = open(image)
          File.open("image.png", "w") do |f|
            f.write file.read
          end
          event.channel.send_file File.new("image.png")
          "More stats: #{response["url"].gsub(" ","%20")}\nTrack your stats and rating live: http://rltracker.pro/live_tracker?player[]=#{response["player"]["id"]}\nAdd me: #{"http://steamcommunity.com/profiles/"+response["player"]["player_id"] if platform == 1}"
        end
      end
    end
  end
end

bot.run