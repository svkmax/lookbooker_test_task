class Event < ActiveRecord::Base
  validates :title, :start_time, :duration, :timezone, :description, presence: true
  validates :duration, numericality: {greater_than: 0}
  validates :email, format: {with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: 'is incorrect'}, presence: true
  validate :validate_timezone

  has_many :activities

  after_create :create_activity

  require 'icalendar/tzinfo'

  default_scope { order('created_at') }

  def validate_timezone
    if Event.get_timezones.exclude?(timezone)
      errors.add(:timezone, " chosen not from the list.")
    end
  end

  # of course in more complex application it should be separate table with the list of supported timezones
  #
  def self.get_timezones
    ["UTC", "Europe/Paris", "CET"]
  end

  def generate_ics
    cal = Icalendar::Calendar.new

    tzid = self.timezone
    tz = TZInfo::Timezone.get tzid
    timezone = tz.ical_timezone self.start_time
    cal.add_timezone timezone

    cal.event do |e|
      e.dtstart = Icalendar::Values::DateTime.new self.start_time, 'tzid' => tzid
      e.dtend = Icalendar::Values::DateTime.new self.start_time + duration.hours, 'tzid' => tzid
      e.summary = self.title
      e.description = self.description
    end
    cal.to_ical
  end

  def send_ics_file
    EventMailer.send_event(self, generate_ics).deliver_now!
    true
  rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError,
      Net::SMTPUnknownError, Net::OpenTimeout, Net::ReadTimeout, IOError
    false
  end

  def create_activity
    # activity should be separated by types
    # but due to simplicity of application just hardcoded
    result = "Failed to send event email to #{email}"
    result = "Event email sent to #{email} on #{Time.now.strftime('%B %e at %l:%M %p')}" if send_ics_file

    Activity.create({result: result, event_id: self.id})
  end

end
