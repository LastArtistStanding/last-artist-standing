# frozen_string_literal: true

RSpec.describe UserFeedbacksController, type: :routing, skip: 'TBD' do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/user_feedbacks').to route_to('user_feedbacks#index')
    end

    it 'routes to #new' do
      expect(get: '/user_feedbacks/new').to route_to('user_feedbacks#new')
    end

    it 'routes to #show' do
      expect(get: '/user_feedbacks/1').to route_to('user_feedbacks#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/user_feedbacks/1/edit').to route_to('user_feedbacks#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/user_feedbacks').to route_to('user_feedbacks#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/user_feedbacks/1').to route_to('user_feedbacks#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/user_feedbacks/1').to route_to('user_feedbacks#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/user_feedbacks/1').to route_to('user_feedbacks#destroy', id: '1')
    end
  end
end
