class AddUserToProxyExercise < ActiveRecord::Migration[5.2]
  def change
    add_reference :proxy_exercises, :user,  polymorphic: true, index: true
    add_column :proxy_exercises, :public, :boolean, null: false, default: false

    internal_user = InternalUser.find_by(id: 46)
    ProxyExercise.update_all(user_id: internal_user.id, user_type: internal_user.class.name)
  end
end
