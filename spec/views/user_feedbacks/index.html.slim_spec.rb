# frozen_string_literal: true

RSpec.describe 'user_feedbacks/index', type: :view, skip: 'TBD' do
  before do
    assign(:user_feedbacks, [
             UserFeedback.create!(
               title: 'Title',
               body: 'Body'
             ),
             UserFeedback.create!(
               title: 'Title',
               body: 'Body'
             )
           ])
  end

  it 'renders a list of user_feedbacks' do
    render
    assert_select 'tr>td', text: 'Title'.to_s, count: 2
    assert_select 'tr>td', text: 'Body'.to_s, count: 2
  end
end
