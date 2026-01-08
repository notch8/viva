# frozen_string_literal: true
module AdministrateHelper
  def humanize_user_role(user)
    user.admin? ? "\nAdmin\n" : "\nUser\n"
  end
end
