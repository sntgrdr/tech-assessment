class CreateExternalIdentities < ActiveRecord::Migration[7.2]
  def change
    create_table :external_identities do |t|
      t.references :person, null: false, foreign_key: true
      t.string :source, null: false
      t.string :external_id, null: false
      t.datetime :last_synced_at
      t.timestamps
    end

    add_index :external_identities,
              [ :source, :external_id ],
              unique: true,
              name: "index_external_identities_on_source_and_external_id"
    add_index :external_identities, :source
  end
end
