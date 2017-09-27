require 'discordrb'
require 'pg'
require './lib/gacha'

bot = Discordrb::Bot.new token: 'Mjk2MjcxOTI2ODc4MjczNTM3.C7v0Pw.hNPMrMNzqrNU2iy3fNSTSJSxzFY',
                        client_id: 296271926878273537

bot.message(content:"ひよこボックス") do |event|
  event.respond hiyokoBox(event.user.name)
end

bot.message(content:/.*うーん.*/) do |event|
  event.respond hiyokoGacha(event.user.name)
end

bot.run
