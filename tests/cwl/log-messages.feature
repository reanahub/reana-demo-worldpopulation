# Tests for the expected log messages

Feature: Log messages

    As a researcher,
    I want to be able to see the log messages of my CWL workflow execution,
    So that I can verify that the workflow ran correctly.

    Scenario: The workflow start has produced the expected messages
        When the workflow is finished
        Then the engine logs should contain "cwltool | MainThread | INFO | [workflow ] start"
        And the engine logs should contain "cwltool | MainThread | INFO | [step worldpopulation] start"

    Scenario: The workflow completion has produced the expected messages
        When the workflow is finished
        Then the engine logs should contain "cwltool | worldpopulation | INFO | [step worldpopulation] completed success"
