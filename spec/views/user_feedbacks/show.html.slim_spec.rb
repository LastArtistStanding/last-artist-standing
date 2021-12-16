# frozen_string_literal: true

RSpec.describe 'user_feedbacks/show', type: :view, skip: 'TBD' do
  before do
    @user_feedback = assign(:user_feedback, UserFeedback.create!(
                                              title: 'Title',
                                              body: 'Body'
                                            ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/Body/)
  end
end
