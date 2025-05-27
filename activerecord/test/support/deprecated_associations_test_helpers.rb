module DeprecatedAssociationsTestHelpers
  class Author < ActiveRecord::Base
    self.table_name = "authors"

    has_many :posts
    has_many :deprecated_posts, class_name: "Post", deprecated: true
  end


  private
    def assert_deprecated_association(association, model = @model, &)
      asserted = false
      mock = ->(reflection) do
        if reflection.active_record == model && reflection.name == association
          asserted = true
        end
      end
      ActiveRecord::Associations::Deprecation.stub(:notify, mock, &)
      assert asserted, "Expected a deprecation notification for #{model}##{association}, but got none"
    end

    def assert_not_deprecated_association(association, model = @model, &)
      mock = ->(reflection) do
        if reflection.active_record == model && reflection.name == association
          raise Minitest::Assertion, "Got a deprecation notification for #{model}##{association}, but expected none"
        end
      end
      ActiveRecord::Associations::Deprecation.stub(:notify, mock, &)
    end
end
