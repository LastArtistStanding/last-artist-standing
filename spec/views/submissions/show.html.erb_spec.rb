require 'spec_helper'

describe "submissions/show" do
  before(:each) do
    @submission = assign(:submission, stub_model(Submission,
      :drawing => "Drawing",
      :thumbnail => "Thumbnail",
      :nsfw_level => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Drawing/)
    rendered.should match(/Thumbnail/)
    rendered.should match(/1/)
  end
end
