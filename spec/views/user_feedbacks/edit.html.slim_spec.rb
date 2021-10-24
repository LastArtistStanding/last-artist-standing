# frozen_string_literal: true

RSpec.describe 'user_feedbacks/edit', type: :view, skip: 'TBD' do
  before do
    @user_feedback = assign(:user_feedback, UserFeedback.create!(
                                              title: 'MyString',
                                              body: 'MyString'
                                            ))
  end

  it 'renders the edit user_feedback form' do
    render

    assert_select 'form[action=?][method=?]', user_feedback_path(@user_feedback), 'post' do
      assert_select 'input[name=?]', 'user_feedback[title]'

      assert_select 'input[name=?]', 'user_feedback[body]'
    end
  end
end
