class PagePolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user
        return scope if user.administrator?
        return scope_user_contributes_to if user.contributor_profile
      end
      scope.joins(:category).where(publish: true, categories: { publish: true })
    end

    private

    def scope_user_contributes_to
      scope.joins(:category, :contributions).where(
        '(pages.publish = true AND categories.publish = true) OR ' \
          'contributions.contributor_profile_id = ?',
        user.contributor_profile_id
      )
    end
  end

  def show?
    if user
      return true if user.administrator?
      return true if user_contributes_to_record?
    end
    record.publish? && record.category.publish?
  end

  def new?
    can_contribute?
  end

  def create?
    new?
  end

  def edit?
    if user
      return true if user.administrator?
      return true if user_contributes_to_record? && !record.publish
    end
  end

  def update?
    edit?
  end

  def destroy?
    if edit?
      return false if record.chapters.length > 0
      return true
    end
  end

  def permitted_attributes
    permitted_attributes = attributes_except_publish
    permitted_attributes << :publish if user && user.administrator?
    permitted_attributes
  end

  private

  def attributes_except_publish
    [
      :page_picture,
      :page_type,
      :parent_page_id,
      :sequence_number,
      :category_id,
      :name,
      :description,
      :content,
      contributor_profile_ids: [],
      tag_ids: [],
      illustrations_attributes: [:id, :illustration, :_destroy]
    ]
  end
end
