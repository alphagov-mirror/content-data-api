class AddLinkToContentItems < ActiveRecord::Migration[5.0]
  def change
    add_column :content_items, :link, :string
  end
end
