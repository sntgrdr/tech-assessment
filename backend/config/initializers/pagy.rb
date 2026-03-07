# config/initializers/pagy.rb
require "pagy/extras/metadata"
require "pagy/extras/overflow"

Pagy::DEFAULT[:items] = 20
Pagy::DEFAULT[:metadata] = %i[count page prev next last from to]
Pagy::DEFAULT[:overflow] = :last_page

Pagy::DEFAULT.freeze
