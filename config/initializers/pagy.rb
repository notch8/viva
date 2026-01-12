require 'pagy/extras/metadata'
require 'pagy/extras/overflow'

Pagy::DEFAULT[:limit] = 10
Pagy::DEFAULT[:overflow] = :last_page
Pagy::DEFAULT[:metadata] = %i[count page prev next prev_url next_url pages limit]
