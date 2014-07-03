module Imageable

  extend ActiveSupport::Concern

  included do
    has_many :images, as: :parent
  end

  #module ClassMethods
  #end

end
