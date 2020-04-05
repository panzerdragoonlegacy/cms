FactoryGirl.define do
  factory :page do
    factory :valid_page do
      sequence(:name) { |n| "Page #{n}" }
      page_type :top_level.to_s
      content 'Test Content'
      page_picture Rack::Test::UploadedFile.new(
        'spec/fixtures/page-picture.jpg', 'image/jpeg'
      )

      contributor_profiles { [FactoryGirl.create(:valid_contributor_profile)] }

      factory :valid_literature_page do
        page_type :literature.to_s
        description 'Test Description'
        category { FactoryGirl.create(:valid_literature_category) }

        factory :published_page_in_published_category do
          publish true
          category { FactoryGirl.create(:published_category) }
        end

        factory :unpublished_page_in_published_category do
          publish false
          category { FactoryGirl.create(:published_category) }
        end

        factory :published_page_in_unpublished_category do
          publish true
          category { FactoryGirl.create(:unpublished_category) }
        end

        factory :unpublished_page_in_unpublished_category do
          publish false
          category { FactoryGirl.create(:unpublished_category) }
        end
      end

      factory :valid_encyclopaedia_page do
        page_type :encyclopaedia.to_s
        information 'Test Information'
        category { FactoryGirl.create(:valid_encyclopaedia_category) }
      end
    end
  end
end
