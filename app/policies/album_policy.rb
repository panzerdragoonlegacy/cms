class AlbumPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user
        return scope if user.administrator?
        if user.contributor_profile.present?
          return scope.joins(:category, :contributions).where(
            "(albums.publish = 't' AND categories.publish = 't') OR " \
              "contributions.contributor_profile_id = ?",
            user.contributor_profile_id
          )
        end
      end
      scope.joins(:category).where(publish: true, categories: { publish: true })
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
    if user
      return true if user.administrator? || user.contributor_profile.present?
    end
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
    if record.pictures.blank?
      edit?
    end
  end

  def permitted_attributes
    permitted_attributes = [
      :category_id,
      :name,
      :description,
      :information,
      contributor_profile_ids: [],
      encyclopaedia_entry_ids: [],
      pictures_attributes: [
        :id,
        :category_id,
        :name,
        :description,
        :information,
        :contributor_profile_ids,
        :encyclopaedia_entry_ids,
        :picture,
        :_destroy
      ]
    ]
    if user
      permitted_attributes << :publish if user.administrator?
    end
    permitted_attributes
  end
end
