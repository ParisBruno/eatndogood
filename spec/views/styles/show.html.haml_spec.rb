require 'rails_helper'

RSpec.describe "styles/show", type: :view do
  before(:each) do
    @style = assign(:style, Style.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
