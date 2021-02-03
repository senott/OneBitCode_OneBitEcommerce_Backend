class AddStatusAndPlatformToLicense < ActiveRecord::Migration[6.0]
  def change
    add_column :licenses, :status, :integer
    add_column :licenses, :platform, :integer
  end
end
