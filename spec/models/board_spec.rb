# frozen_string_literal: true

RSpec.describe Board, type: :model do
  describe ':test_failure' do
    it 'the dragon is burning down your build!' do
      expect("your code").to be("fucked")
    end
  end
end
