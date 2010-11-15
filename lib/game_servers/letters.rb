require File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment')
require 'em_channel_patch'

EventMachine.run do
  @lobbies = {}

  Lobby = Struct.new(:channel, :letters)
  Letter = Struct.new(:x, :y)

  def find_or_create_lobby(channel_id)
    @lobbies[channel_id] ||= Lobby.new(EM::Channel.new, ((0...78).collect { Letter.new(rand(800), rand(400)) }))
  end

  EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8081) do |ws|
    ws.onopen do
      lobby = find_or_create_lobby(ws.request['Path'].split('/').last)
      socket_id = lobby.channel.subscribe{|msg| ws.send msg}
      puts "open #{lobby.channel} #{socket_id}"

      # player count
      lobby.channel.push ['playerCount', lobby.channel.subs].to_json

      # load letter positions
      lobby.letters.each_with_index do |letter, index|
        ws.send ['move', [index, letter.x, letter.y]].to_json
      end

      ws.onmessage do |msg|
        event, data = JSON.parse(msg)
        case event
          when 'move'
            lobby.letters[data[0]].x = data[1] if (data[1] >= 0 || data[1] <= 930)
            lobby.letters[data[0]].y = data[2] if (data[2] >= 0 || data[2] <= 445)

            lobby.channel.push_to_others(socket_id, [event, data].to_json)
        end
      end

      ws.onclose do
        lobby.channel.unsubscribe(socket_id)
        lobby.channel.push ['playerCount', lobby.channel.subs].to_json
        puts "close #{lobby.channel} #{socket_id}"
      end
    end
  end
end
