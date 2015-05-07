require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  describe 'POST create' do
    let(:event) { attributes_for(:event) }
    let(:create_params) { {event: event} }
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
        expect { create_request }.to change { Event.count }.by(1)
      end

      it 'should have new activity' do
        expect { create_request }.to change { Activity.count }.by(1)
      end

    end
  end
end
