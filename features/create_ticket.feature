Feature: Ticket creation
  I want to create tickets via SMS

  Scenario: SMS
    When I send a SMS message to "+18644385266" with the following:
      """
      How do I turn this on?
      """
    Then I should see "Got it!"
