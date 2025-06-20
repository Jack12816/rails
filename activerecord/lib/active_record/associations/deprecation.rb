# frozen_string_literal: true

require "active_support/notifications"

module ActiveRecord::Associations::Deprecation # :nodoc:
  class << self
    def guard(reflection)
      notify(reflection) if reflection.deprecated?

      if reflection.through_reflection?
        if habtm_reflection = reflection.options[:_habtm_reflection]
          notify(habtm_reflection) if habtm_reflection.deprecated?
        else
          reflection.deprecated_nested_reflections.each { notify(_1) }
        end
      end
    end

    def notify(reflection)
      ActiveRecord::Base.logger&.warn("The association #{reflection.active_record}##{reflection.name} is deprecated")
      ActiveSupport::Notifications.instrument("deprecated_association.active_record", reflection: reflection)
    end
  end
end
