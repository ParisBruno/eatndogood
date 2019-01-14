require 'rails_helper'

RSpec.describe "allergens/new", type: :view do
  before(:each) do
    assign(:allergen, Allergen.new(
      :name => "MyString",
      :user_id => 1
    ))
  end

  it "renders new allergen form" do
    render

    assert_select "form[action=?][method=?]", allergens_path, "post" do

      assert_select "input[name=?]", "allergen[name]"

      assert_select "input[name=?]", "allergen[user_id]"
    end
  end
end
