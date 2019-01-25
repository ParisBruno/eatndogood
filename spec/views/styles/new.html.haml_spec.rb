require 'rails_helper'

RSpec.describe "styles/new", type: :view do
  before(:each) do
    assign(:style, Style.new())
  end

  it "renders new style form" do
    render

    assert_select "form[action=?][method=?]", styles_path, "post" do
    end
  end
end
