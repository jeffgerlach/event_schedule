class ScheduleController < ApplicationController
  def index
    @schedules = Schedule.all.order("event_date ASC")
  end

  def show
    @tracks = []
    Event.all.where("shared_with_all = ?", false).order("track_name ASC").each do |event|
      @tracks.push(event.track_name) unless @tracks.include?(event.track_name)
    end
    @tracks.sort!{|x,y| Track.where("track_name = ?", x).first.display_order <=> Track.where("track_name = ?", y).first.display_order}
    @schedule = Schedule.find(params[:id])
    @current_events = Event.where("start_time >= ? AND start_time <= ?", @schedule.event_date.to_datetime, @schedule.event_date.to_datetime + 1.days).order("start_time ASC")
    @earliest_event_time = @current_events.first
    @latest_event_time = @current_events.last
    @event_durations = @current_events.map {|event| (event.end_time.to_i - event.start_time.to_i)/60}
    @block_time = @event_durations.reduce(:gcd)
    @time_periods = []
    curr_time = @earliest_event_time.start_time
    begin
      @time_periods << curr_time
      curr_time += @block_time.minutes
    end while curr_time < @latest_event_time.end_time
    @common_event_start_times = []
  end

  private

  helper_method :generate_schedule_td

  def generate_schedule_td(time, track_name)
    time_slot = ""
    find_event = schedule_time_query(time, track_name)
    if find_event.empty?
      common_event = find_shared_event(time)
      if common_event.empty?
        time_slot += "<td> </td>"
      elsif common_event.first.start_time.round_to(@block_time.minutes).strftime("%H%M") == time.round_to(@block_time.minutes).strftime("%H%M") &&  !@common_event_start_times.include?(common_event.first.start_time) # start of slot, display nameC
        curr_event = common_event.shift
        time_slot += "<td colspan=\"5\" rowspan=\"#{((curr_event.end_time.round_to(@block_time.minutes)-curr_event.start_time.round_to(@block_time.minutes))/@block_time.minutes).to_s}\" bgcolor=\"#C7C3C3\"> <b>#{curr_event.course_name}</b><br/>#{curr_event.start_time.strftime("%H%M")}-#{curr_event.end_time.strftime("%H%M")} </td>"
        @common_event_start_times << curr_event.start_time
        while !common_event.empty?
          time_slot += "<br/>------------------<br/><b>#{curr_event.course_name}</b><br/>#{curr_event.start_time.strftime("%H%M")}-#{curr_event.end_time.strftime("%H%M")} "
          curr_event = common_event.shift
        end
        time_slot += "</td>"
      else
        time_slot
      end
    else
      if find_event.first.start_time.round_to(@block_time.minutes).strftime("%H%M") == time.round_to(@block_time.minutes).strftime("%H%M")
        curr_event = find_event.shift
        time_slot += "<td rowspan=\"#{((curr_event.end_time.round_to(@block_time.minutes)-curr_event.start_time.round_to(@block_time.minutes))/@block_time.minutes).to_s}\" bgcolor=\"#5AACE4\"> <b>#{curr_event.course_name}</b><br/>#{curr_event.start_time.strftime("%H%M")}-#{curr_event.end_time.strftime("%H%M")} "
        while !find_event.empty?
          time_slot += "<br/>------------------<br/><b>#{curr_event.course_name}</b><br/>#{curr_event.start_time.strftime("%H%M")}-#{curr_event.end_time.strftime("%H%M")} "
          curr_event = find_event.shift
        end
        time_slot += "</td>"
      else
        time_slot
      end
    end
  end

  def find_shared_event(time)
    shared_events = @current_events.select{|event| event.shared_with_all}
    time_plus_date = time
    active_shared_event = shared_events.select{|event| time_plus_date.between?(event.start_time, event.end_time) && (event.end_time != time_plus_date)}
    active_shared_event
  end

  def schedule_time_query(time, track_name)
    time_plus_date = time
    active_event = @current_events.select{|event| time_plus_date.between?(event.start_time, event.end_time) && (event.end_time != time_plus_date) && (event.track_name == track_name)}
    active_event #should only have one
  end



end
