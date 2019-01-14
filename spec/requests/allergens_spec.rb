require 'rails_helper'

RSpec.describe "Allergens", type: :request do
  describe "GET /allergens" do
    it "works! (now write some real specs)" do
      get allergens_path
      expect(response).to have_http_status(200)
    end
  end
end
