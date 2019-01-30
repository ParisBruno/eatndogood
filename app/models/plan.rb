# frozen_string_literal: true
class Plan < ApplicationRecord
  has_many :users
  belongs_to :plan_category

  validates :title, presence: true, uniqueness: true

  def create_new_plans
  	family_cate = PlanCategory.where(name: 'Family & Friends').first
  	professional_cate = PlanCategory.where(name: 'Professionals').first
  	entrep_cate = PlanCategory.where(name: 'Entrepreneurs').first
  	enterprise_cate = PlanCategory.where(name: 'Enterprise').first
  	
  	plans = [
  	  
  	  {
  	    code: 'V1',
  	    title: '10 chefs',
  	    chefs_limit: 10,
  	    guests_limit: 0,
  	    recipes_limit: 110,
  	    plan_category_id: !family_cate.nil? ? family_cate.id : 0
  	  },
  	  {
  	    code: 'V2',
  	    title: '20 chefs',
  	    chefs_limit: 20,
  	    guests_limit: 0,
  	    recipes_limit: 220,
  	    plan_category_id: !family_cate.nil? ? family_cate.id : 0
  	  },
  	  {
  	    code: 'V1',
  	    title: '100 guests',
  	    chefs_limit: 1,
  	    guests_limit: 100,
  	    recipes_limit: 110,
  	    plan_category_id: !professional_cate.nil? ? professional_cate.id : 0
  	  },
  	  {
  	    code: 'V2',
  	    title: '250 guests',
  	    chefs_limit: 1,
  	    guests_limit: 250,
  	    recipes_limit: 110,
  	    plan_category_id: !professional_cate.nil? ? professional_cate.id : 0
  	  },
  	  {
  	    code: 'V1',
  	    title: '250 guests',
  	    guests_limit: 250,
  	    recipes_limit: 150,
  	    plan_category_id: !entrep_cate.nil? ? entrep_cate.id : 0
  	  },
  	  {
  	    code: 'V2',
  	    title: '500 guests',
  	    guests_limit: 500,
  	    recipes_limit: 150,
  	    plan_category_id: !entrep_cate.nil? ? entrep_cate.id : 0
  	  },
  	  {
  	    code: 'V3',
  	    title: '1000 guests',
  	    guests_limit: 1000,
  	    recipes_limit: 150,
  	    plan_category_id: !entrep_cate.nil? ? entrep_cate.id : 0
  	  },
  	  {
  	      title: 'Enterprise',
  	      recipes_limit: 200,
  	      plan_category_id: !enterprise_cate.nil? ? enterprise_cate.id : 0
  	  },
  	  {
  	      title: 'Free',
  	      chefs_limit: 0,
  	      guests_limit: 0,
  	      recipes_limit: 10
  	  }
  	]

  	plans.each do |plan|
  	  Plan.find_or_create_by(plan)
  	end
  end
end
