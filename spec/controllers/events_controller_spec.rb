require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  describe 'POST create' do
    let(:event) { attributes_for(:event) }
    let(:create_params) { {event: event } }
    let(:create_request) { post :create, create_params }
    context 'response' do
      before { create_request }

      it 'should redirect to show' do
        expect(response).to redirect_to :action => :show,
                                        :id => assigns(:event).id
      end
    end
    context 'in database' do
      it 'should have new event' do
        expect{create_request}.to change{Event.count}.by(1)
      end

      it 'should have new activity' do
        expect{create_request}.to change{Activity.count}.by(1)
      end

      context 'Event' do
        before { create_request }
        let(:db_event) {Event.last}
        it 'should have event title' do
          expect(db_event.title).to eq event[:title]
        end

        it 'should have event email' do
          expect(db_event.email).to eq event[:email]
        end

        it 'should have event timezone' do
          expect(db_event.timezone).to eq event[:timezone]
        end

        it 'should have event description' do
          expect(db_event.description).to eq event[:description]
        end

        it 'should have event start_time' do
          expect(db_event.start_time).to eq event[:start_time]
        end

        it 'should have event duration' do
          expect(db_event.duration).to eq event[:duration].to_f
        end

      end
    end
  end
end
