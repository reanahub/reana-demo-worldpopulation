# Tests for the expected log messages

Feature: Log messages

    As a researcher,
    I want to be able to see the log messages of my Yadage workflow execution,
    So that I can verify that the workflow ran correctly.

    Scenario: The workflow start has produced the expected messages
        When the workflow is finished
        Then the engine logs should contain "adage.node | MainThread | INFO | node ready </init:0|success|known>"
        And the engine logs should contain "yadage.wflowview | MainThread | INFO | added </worldpopulation:0|defined|unknown>"

    Scenario: The workflow completion has produced the expected messages
        When the workflow is finished
        Then the engine logs should contain "adage | MainThread | INFO | workflow completed successfully."
