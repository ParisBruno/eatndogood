require 'rails_helper'

RSpec.describe "allergens/index", type: :view do
  before(:each) do
    assign(:allergens, [
      Allergen.create!(
        :name => "Name",
        :user_id => 2
      ),
      Allergen.create!(
        :name => "Name",
        :user_id => 2
      )
    ])
  end

  it "renders a list of allergens" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
