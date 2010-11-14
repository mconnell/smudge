require File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment')
require 'em_channel_patch'


EventMachine.run do
  @lobbies = {}
  @count = 180

  Lobby = Struct.new(:channel, :data)

  def find_or_create_lobby(channel_id)
    @lobbies[channel_id] ||= Lobby.new(EM::Channel.new, [])
  end

  EventMachine::PeriodicTimer.new(180) do
    @lobbies.each_value do |lobby|
      lobby.data = []
      lobby.channel.push ['clear', {}].to_json
    end
  end

  EventMachine::PeriodicTimer.new(1) do
    @count -= 1 if @count > 0
  end

  EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|
    ws.onopen do
      lobby = find_or_create_lobby(ws.request['Path'].split('/').last)
      socket_id = lobby.channel.subscribe{|msg| ws.send msg}
      puts "open #{lobby.channel} #{socket_id}"

      # set countdown timer
      ws.send ['startTimer', @count].to_json

      # load in existing paths
      lobby.data.each do |data|
        ws.send ['draw', data].to_json
      end

      ws.onmessage do |msg|
        event, data = JSON.parse(msg)
        case event
          when 'draw'
            lobby.data << data
            lobby.channel.push_to_others(socket_id, [event, data].to_json)
        end
      end

      ws.onclose do
        lobby.channel.unsubscribe(socket_id)
        puts "close #{lobby.channel} #{socket_id}"
      end
    end
  end
end
