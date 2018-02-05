require 'spec_helper'

describe "submissions/new" do
  before(:each) do
    assign(:submission, stub_model(Submission,
      :drawing => "MyString",
      :thumbnail => "MyString",
      :nsfw_level => 1
    ).as_new_record)
  end

  it "renders new submission form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", submissions_path, "post" do
      assert_select "input#submission_drawing[name=?]", "submission[drawing]"
      assert_select "input#submission_thumbnail[name=?]", "submission[thumbnail]"
      assert_select "input#submission_nsfw_level[name=?]", "submission[nsfw_level]"
    end
  end
end
