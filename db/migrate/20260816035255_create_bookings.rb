class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.references :provider, null: false, foreign_key: true
      t.string :client_name
      t.string :client_email
      t.datetime :starts_at
      t.datetime :ends_at
      t.text :note

      t.timestamps
    end

    add_index :bookings, [ :provider_id, :starts_at ], unique: true
  end
end
