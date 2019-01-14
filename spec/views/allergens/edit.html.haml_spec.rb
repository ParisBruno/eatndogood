require 'rails_helper'

RSpec.describe "allergens/edit", type: :view do
  before(:each) do
    @allergen = assign(:allergen, Allergen.create!(
      :name => "MyString",
      :user_id => 1
    ))
  end

  it "renders the edit allergen form" do
    render

    assert_select "form[action=?][method=?]", allergen_path(@allergen), "post" do

      assert_select "input[name=?]", "allergen[name]"

      assert_select "input[name=?]", "allergen[user_id]"
    end
  end
end
