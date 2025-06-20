# frozen_string_literal: true

module DeprecatedAssociationsTestHelpers
  private
    def assert_deprecated_association(association, model = @model, &)
      notified = false
      mock = ->(reflection) do
        notified = true if reflection.active_record == model && reflection.name == association
      end
      ActiveRecord::Associations::Deprecation.stub(:notify, mock, &)
      assert notified, "Expected a notification for #{model}##{association}, but got none"
    end

    def assert_not_deprecated_association(association, model = @model, &)
      notified = false
      mock = ->(reflection) do
        notified = true if reflection.active_record == model && reflection.name == association
      end
      ActiveRecord::Associations::Deprecation.stub(:notify, mock, &)
      assert_not notified, "Got a notification for #{model}##{association}, but expected none"
    end
end
