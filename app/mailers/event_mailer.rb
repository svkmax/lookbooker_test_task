class EventMailer < ActionMailer::Base
    default from: "from@example.com"

    def send_event event, event_string
      @title = event.title
      attachments['test.ics'] = { :mime_type => 'text/calendar',:content => event_string }
      mail(to: event.email, subject: "new Event") do |f|
          f.html { render 'mails/event_mail.html.slim' }
        end
    end
end