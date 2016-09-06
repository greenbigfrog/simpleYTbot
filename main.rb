require 'bundler/setup'

require 'pry'

require 'dotenv'
Dotenv.load if ENV['TOKEN'].nil?

require 'yt'

Yt.configure do |config|
  config.api_key = ENV['APIKEY']
end

require 'discordrb'

bot = Discordrb::Commands::CommandBot.new token: ENV['TOKEN'], application_id: ENV['APPID'], prefix: 'yt, ', advanced_functionality: false, debug: true #, log_mode: :debug

bot.command(:invite, description: 'Add the bot to your server') do |event|
  "You can add this bot to your server. #{bot.invite_url}"
end

bot.command(:stats, description: 'shows a few stats about the bot') do |event|
  members = 0
  event.bot.servers.each { |x, y| members = members + y.member_count }
  "Currently I'm on **#{event.bot.servers.size} servers** with a total user count of **#{members} users** in **#{event.bot.servers.collect { |x, y| y.channels.size }.inject(0, &:+)} channels**!"
end

bot.command(:simple, description: 'GIves you an invite to the bots help server') do |event|
  "For help etc. join the bots support server at https://discord.me/simplesupport"
end

yt_regex = %r{
    (?:youtube(?:-nocookie)?\.com\/
    (?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|
    \S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})
    }x

bot.message(contains: 'youtu') do |event|
  ids = event.content.scan(yt_regex)

  unless ids.empty?
    ids.each do |id|
      vid = Yt::Video.new id: id.first

      msg = ""
      msg << "```md\n"
      msg << "# #{vid.title}\n"
      msg << "[Description][#{vid.description}]\n"
      msg << "[Views][#{vid.view_count}]\n"
      msg << "[Length][#{Time.at(vid.duration).utc.strftime("%H:%M:%S")}]\n"
      msg << "[Likes/Dislikes][#{vid.like_count}/#{vid.dislike_count}]\n"
      msg << "```"
      event.respond msg
    end
  end
  nil
end

bot.run :async
bot.profile.game = 'with YT'

bot.sync