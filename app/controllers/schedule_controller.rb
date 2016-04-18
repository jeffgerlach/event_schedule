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
    @tracks = []
    Event.all.where("shared_with_all = ?", false).order("track_name ASC").each do |event|
      @tracks.push(event.track_name) unless @tracks.include?(event.track_name)
    end
    @schedule = Schedule.find(params[:id])
    @current_events = Event.where("start_time >= ? AND start_time <= ?", @schedule.event_date.to_datetime, @schedule.event_date.to_datetime + 1.days)


  end

  private

  helper_method :generate_schedule_td

  def generate_schedule_td(time, track_name)
    time_slot = "<td"

    common_event = find_shared_event(time)
    if common_event.nil?
      find_event = schedule_time_query(time, track_name)
      #binding.pry
      if find_event.nil?
        time_slot += "> </td>"
      else #find_event.start_time.hour == time.to_time.hour # start of slot, display name
        time_slot += " bgcolor=\"#5AACE4\"> #{find_event.course_name} </td>"
      #else
        #time_slot += ' bgcolor="#5AACE4"> </td>'
      end
    else
      time_slot += " bgcolor=\"#C7C3C3\"> #{common_event.course_name} </td>"
    end
  end

  def find_shared_event(time)
    shared_events = @current_events.select{|event| event.shared_with_all}
    active_shared_event = shared_events.select{|event| (event.start_time.strftime("%H%M") >= time.to_time.strftime("%H%M")) && (event.end_time.strftime("%H%M") <= (time.to_time + 30.minutes).strftime("%H%M"))}
    active_shared_event.first
  end

  def schedule_time_query(time, track_name)
    active_event = @current_events.select{|event| (event.start_time.strftime("%H%M") >= time.to_time.strftime("%H%M")) && (event.end_time.strftime("%H%M") <= (time.to_time + 30.minutes).strftime("%H%M")) && (event.track_name == track_name)}
    #binding.pry
    #if active_event.nil?
    #  return nil
    #else
    #  active_event.start_time.hour == time.to_time.hour
    #end
    active_event.first #should only have one
  end

end
