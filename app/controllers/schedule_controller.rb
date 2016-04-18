class ScheduleController < ApplicationController
  def index
    #@events = Event.all.order("start_time ASC")
    #@date_list = []
    #@events.each do |event|
      #event_day = event.start_time.strftime("%d %b %Y")
      #@date_list | [event_day] #add date to list if unique <- wasn't working, need to investigate
      # there is a more efficient way to do this, would update given time
      #@date_list.push(event_day) unless @date_list.include?(event_day)
    #end
    @schedules = Schedule.all.order("event_date ASC")
  end

  def show
    @schedule = Schedule.find(params[:id])
    @current_events = Event.where("start_time >= ? AND start_time <= ?", @schedule.event_date.to_datetime, @schedule.event_date.to_datetime + 1.days)
  end
end
