class AddProductToDevice < ActiveRecord::Migration[5.0]
  def change
    add_reference :devices, :product, foreign_key: true
  end
end
