class CreatePeople < ActiveRecord::Migration[7.2]
  def change
    create_table :people do |t|
      t.string :email, null: false
      t.string :phone
      t.string :company
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :job_title
      t.string :department
      t.string :manager_email
      t.date :start_date

      t.timestamps
    end

    add_index :people, "lower(email)", unique: true, name: "index_people_on_lower_email"
    add_index :people, :phone
    add_index :people, :company
    add_index :people, :job_title
    add_index :people, :manager_email
    add_index :people, :department
  end
end
