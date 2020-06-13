# typed: true

require 'active_record'
require 'sorbet-runtime'

module Models
  extend T::Sig

  class HnItem < ActiveRecord::Base
    self.primary_key = 'hn_id'
  end
end
