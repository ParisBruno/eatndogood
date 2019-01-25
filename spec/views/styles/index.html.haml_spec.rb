require 'rails_helper'

RSpec.describe "styles/index", type: :view do
  before(:each) do
    assign(:styles, [
      Style.create!(),
      Style.create!()
    ])
  end

  it "renders a list of styles" do
    render
  end
end
