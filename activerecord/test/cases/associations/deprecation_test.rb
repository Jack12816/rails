# frozen_string_literal: true

require "cases/helper"
require "models/dats"

# The logic of the `guard` method is extensively tested indirectly, via the test
# suites of each type of association.
#
# Those tests verify that the `notify` method is invoked as expected. Here, we
# unit test the `notify` method itself.
class AssociationDeprecationTest < ActiveRecord::TestCase
  test "notify issues a warning" do
    messages = []

    ActiveRecord::Base.logger.stub(:warn, ->(message) { messages << message }) do
      DATS::Car.new.tyres
      DATS::Car.new.deprecated_tyres
    end

    assert_not_includes messages, "The association DATS::Car#tyres is deprecated"
    assert_includes messages, "The association DATS::Car#deprecated_tyres is deprecated"
  end

  test "notify issues an Active Support notification" do
    reflections = []

    callback = ->(_name, _started, _finished, _unique_id, payload) do
      reflections << payload[:reflection]
    end

    ActiveSupport::Notifications.subscribed(callback, "deprecated_association.active_record") do
      DATS::Car.new.tyres
      DATS::Car.new.deprecated_tyres
    end

    assert_not_includes reflections, DATS::Car.reflect_on_association(:tyres)
    assert_includes reflections, DATS::Car.reflect_on_association(:deprecated_tyres)
  end
end
