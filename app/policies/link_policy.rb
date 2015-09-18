class LinkPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user
        return scope if user.administrator
      end
      scope.joins(:category).where(categories: { publish: true })
    end
  end

  def show?
    if user
      return true if user.administrator
    end
    record.category.publish?
  end
end
