require 'rails_helper'

describe SagaPolicy do
  subject { described_class.new(user, saga) }

  let(:resolved_scope) do
    described_class::Scope.new(user, Saga.all).resolve
  end

  let(:user) { FactoryBot.create(:administrator) }

  context 'administrator accessing a saga' do
    let(:saga) { FactoryBot.create(:valid_saga) }

    it 'includes saga in resolved scope' do
      expect(resolved_scope).to include(saga)
    end

    it do
      is_expected.to permit_actions([:show, :new, :create, :edit, :update])
    end

    context 'saga has no children' do
      it { is_expected.to permit_action(:destroy) }
    end

    context 'saga has children' do
      before do
        saga.categories << FactoryBot.create(
          :published_category_in_saga
        )
      end

      it { is_expected.to forbid_action(:destroy) }
    end
  end
end
