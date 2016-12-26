require 'rails_helper'

describe ResourcePolicy do
  subject { described_class.new(user, resource) }

  let(:resolved_scope) do
    described_class::Scope.new(user, Resource.all).resolve
  end

  context 'being a visitor' do
    let(:user) { nil }

    context 'creating a new resource' do
      let(:resource) { Resource.new }

      it { is_expected.to forbid_new_and_create_actions }
      it { is_expected.to forbid_mass_assignment_of(:publish) }
    end

    context 'accessing resources in a published category' do
      context 'accessing a published resource' do
        let(:resource) do
          FactoryGirl.create(:published_resource_in_published_category)
        end

        it 'includes resource in resolved scope' do
          expect(resolved_scope).to include(resource)
        end

        it { is_expected.to permit_action(:show) }
        it { is_expected.to forbid_edit_and_update_actions }
        it { is_expected.to forbid_action(:destroy) }
        it { is_expected.to forbid_mass_assignment_of(:publish) }
      end

      context 'accessing an unpublished resource' do
        let(:resource) do
          FactoryGirl.create(:unpublished_resource_in_published_category)
        end

        it 'excludes resource from resolved scope' do
          expect(resolved_scope).not_to include(resource)
        end

        it { is_expected.to forbid_action(:show) }
        it { is_expected.to forbid_edit_and_update_actions }
        it { is_expected.to forbid_action(:destroy) }
        it { is_expected.to forbid_mass_assignment_of(:publish) }
      end
    end

    context 'accessing resources in an unpublished category' do
      context 'accessing a published resource' do
        let(:resource) do
          FactoryGirl.create(:published_resource_in_unpublished_category)
        end

        it 'excludes resource from resolved scope' do
          expect(resolved_scope).not_to include(resource)
        end

        it { is_expected.to forbid_action(:show) }
        it { is_expected.to forbid_edit_and_update_actions }
        it { is_expected.to forbid_action(:destroy) }
        it { is_expected.to forbid_mass_assignment_of(:publish) }
      end

      context 'accessing an unpublished resource' do
        let(:resource) do
          FactoryGirl.create(:unpublished_resource_in_unpublished_category)
        end

        it 'excludes resource from resolved scope' do
          expect(resolved_scope).not_to include(resource)
        end

        it { is_expected.to forbid_action(:show) }
        it { is_expected.to forbid_edit_and_update_actions }
        it { is_expected.to forbid_action(:destroy) }
        it { is_expected.to forbid_mass_assignment_of(:publish) }
      end
    end
  end
end