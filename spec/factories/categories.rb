FactoryGirl.define do
  factory :category do
    factory :valid_category do
      sequence(:name) { |n| "Category #{n}" }
      sequence(:short_name) { |n| "Cat #{n}" }
      description 'Test Description'
      category_type :story

      factory :valid_picture_category do
        category_type :picture
        category_group { FactoryGirl.create(:valid_picture_category_group) }
      end

      factory :published_category do
        publish true
      end

      factory :unpublished_category do
        publish false
      end
    end
  end
end
