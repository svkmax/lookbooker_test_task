class Event < ActiveRecord::Base
  validates_presence_of :title, :start_time, :duration, :timezone, :email, :description
  validates_numericality_of :duration, greater_than: 0
  validate :validate_email
  validate :validate_timezone

  has_many :activities

  require 'icalendar/tzinfo'

  default_scope { order('created_at') }

  def validate_email
    unless email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      errors.add(:email, " field value is not looked like email")
    end
  end

  def validate_timezone
    unless Event.get_timezones.include?(timezone)
      errors.add(:timezone, " is unsupported value for now")
    end
  end

  # of course in more complex application it should be separate table with the list of supported timezones
  #
  def self.get_timezones
    ["UTC", "Europe/Paris", "CET"]
  end

  def generate_ics
    cal = Icalendar::Calendar.new

    event_start = self.start_time
    event_end = self.start_time + duration.hours

    tzid = self.timezone
    tz = TZInfo::Timezone.get tzid
    timezone = tz.ical_timezone event_start
    cal.add_timezone timezone

    cal.event do |e|
      e.dtstart = Icalendar::Values::DateTime.new event_start, 'tzid' => tzid
      e.dtend   = Icalendar::Values::DateTime.new event_end, 'tzid' => tzid
      e.summary = self.title
      e.description = self.description
    end
    cal.to_ical
  end

  def send_ics_file
    cal_string = generate_ics
    begin
      EventMailer.send_event(self, cal_string).deliver_now!
    rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError,
        Net::SMTPUnknownError, Net::OpenTimeout, Net::ReadTimeout, IOError
      return false
    end
    return true
  end

  def create_activity
     # activity should be separated by types
     # but due to simplicity of application just hardcoded
     result = "Failed to send event email to #{email}"
     result = "Event email sent to #{email} on #{Time.now.strftime('%B %e at %l:%M %p')}" if send_ics_file

     Activity.create!({result: result, event_id: self.id})
  end

end
