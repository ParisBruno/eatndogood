require 'rails_helper'

RSpec.describe Page, type: :model do
  describe "#get_destination" do
    it "fetch destination name for edit page" do
      result = Page.get_destination("/pages/welcome/some/path")

      expect(result).to eq("welcome")
    end
  end
end
