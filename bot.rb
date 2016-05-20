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
    "'!help rltracker.pro' is a command though"
  end
end

bot.command [:rank, :ranks] do |event|
  "Please use !stats instead of rank. We aren't some kind of second class tool!"
end

bot.command [:stats, :stat] do |event, platform, user_id, negated|
  platform = platform && platform.downcase
  unless ["steam", "originators", "pc", "sites", "ps4", "xbox", "help", "github", "dev"].include? platform
    return "Please dont forget to specify the platform (steam/pc/ps4/xbox).\nFor more help please use !help rltracker.pro"
  else
    if user_id == nil
      case platform
        when "dev"
          return "Quent#6782 did the concept of the Bot and Yixn#9503 redeveloped it."
        when "sites"
          return "Featured by http://rltracker.pro, partnered with http://prorl.com"
        when "originators"
          return "Featured by http://rltracker.pro, partnered with http://prorl.com"
        when "help"
          return help
        when "github"
          return "https://github.com/rltracker/rl_discord_bot"
        else
          return "Please include a UserID like:\n!stat steam yixn.\nFor more help please use !help rltracker.pro"
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
        return "ProspectScrub"
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
          out = "Cant find Player. Please use your "
          case platform
            when 1
              out += "vanityurl or steamID64\nIf you are not sure about which id to use, please refer to https://steamid.io."
            when 2
              out += "ps4 username."
            when 3
              out += "xbox username."
          end
          return out + "\nFor more help please use !help rltracker.pro"
        else
          file = open(image)
          File.open("image.png", "w") do |f|
            f.write file.read
          end
          event.channel.send_file File.new("image.png")
          out = "More stats: #{response["url"].gsub(" ", "%20")}"
          out += "\nTrack your stats and rating live: http://rltracker.pro/live_tracker?player[]=#{response["player"]["id"]}"
          if platform == 1
            out += "\nAdd me: http://steamcommunity.com/profiles/#{response["player"]["player_id"]}"
          end
          return out
        end
      end
    end
  end
end

def help
  <<-EOF.gsub(/^  /, "")
  !stats {platform} {user_id} {white}

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
  EOF
end

bot.run