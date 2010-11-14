module EventMachine
  class Channel

    def push_to_others(sid, *items)
      subs = @subs.dup
      subs.delete(sid)

      items = items.dup
      EM.schedule { subs.values.each { |s| items.each { |i| s.call i } } }
    end
    alias << push_to_others

  end
end
