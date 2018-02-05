require 'spec_helper'

describe "submissions/index" do
  before(:each) do
    assign(:submissions, [
      stub_model(Submission,
        :drawing => "Drawing",
        :thumbnail => "Thumbnail",
        :nsfw_level => 1
      ),
      stub_model(Submission,
        :drawing => "Drawing",
        :thumbnail => "Thumbnail",
        :nsfw_level => 1
      )
    ])
  end

  it "renders a list of submissions" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Drawing".to_s, :count => 2
    assert_select "tr>td", :text => "Thumbnail".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
