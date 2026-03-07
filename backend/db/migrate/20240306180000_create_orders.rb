class CreateOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :orders do |t|
      t.references :person, null: false, foreign_key: true
      t.string :number, null: false
      t.string :status, default: 'pending', null: false
      t.decimal :total_amount, precision: 10, scale: 2, default: 0.0, null: false
      t.text :notes
      t.date :order_date, null: false

      t.timestamps null: false
    end

    # Single column indexes with custom names to avoid conflicts
    add_index :orders, :person_id, name: 'index_orders_on_person_id_fk'
    add_index :orders, :order_date, name: 'index_orders_on_order_date'
    add_index :orders, :number, unique: true, name: 'index_orders_on_number_unique'
    add_index :orders, :status, name: 'index_orders_on_status'
    add_index :orders, :created_at, name: 'index_orders_on_created_at'

    # Compound indexes (user requested) with custom names
    add_index :orders, [ :person_id, :order_date, :status ], name: 'index_orders_on_person_date_status'
    add_index :orders, [ :person_id, :status ], name: 'index_orders_on_person_status'
    add_index :orders, [ :person_id, :order_date ], name: 'index_orders_on_person_date'
    add_index :orders, [ :person_id, :number ], name: 'index_orders_on_person_number'
    add_index :orders, [ :order_date, :status ], name: 'index_orders_on_date_status'
    add_index :orders, [ :number, :status ], name: 'index_orders_on_number_status'
    add_index :orders, [ :number, :status, :order_date ], name: 'index_orders_on_number_status_date'

    # Performance optimization indexes with custom names
    add_index :orders, [ :person_id, :created_at ], name: 'index_orders_on_person_created_at'
    add_index :orders, [ :status, :created_at ], name: 'index_orders_on_status_created_at'
    add_index :orders, [ :order_date, :person_id ], name: 'index_orders_on_date_person'
    add_index :orders, [ :status, :order_date ], name: 'index_orders_on_status_date_alt'
    add_index :orders, [ :person_id, :status, :order_date ], name: 'index_orders_on_person_status_date_alt'
  end
end
