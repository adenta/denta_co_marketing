class ChatPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    owns_record?
  end

  def create?
    user.present?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless user

      scope.where(user_id: user.id)
    end
  end

  private

  def owns_record?
    user.present? && record.respond_to?(:user_id) && record.user_id == user.id
  end
end
