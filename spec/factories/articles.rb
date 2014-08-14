FactoryGirl.define do
  factory :article do
    factory :valid_article do
      sequence(:name) { |n| "Article #{n}" }
      description "Test Description"
      content "Test Content"

      category { FactoryGirl.create(:category) }
      dragoons { [FactoryGirl.create(:dragoon)] }

      factory :published_article_in_published_category do
        publish true
        category { FactoryGirl.create(:published_category) }
      end

      factory :unpublished_article_in_published_category do
        publish false
        category { FactoryGirl.create(:published_category) }
      end
    end
  end
end