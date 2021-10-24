# frozen_string_literal: true

RSpec.describe 'user_feedbacks/new', type: :view, skip: 'TBD' do
  before do
    assign(:user_feedback, UserFeedback.new(
                             title: 'MyString',
                             body: 'MyString'
                           ))
  end

  it 'renders new user_feedback form' do
    render

    assert_select 'form[action=?][method=?]', user_feedbacks_path, 'post' do
      assert_select 'input[name=?]', 'user_feedback[title]'

      assert_select 'input[name=?]', 'user_feedback[body]'
    end
  end
end
