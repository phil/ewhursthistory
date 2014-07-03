class AddPubAndPaymentToPublications < ActiveRecord::Migration
  def change
    add_column :publications, :published_on, :date
    add_column :publications, :payment_information, :text
  end
end
