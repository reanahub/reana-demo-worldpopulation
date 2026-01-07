# Tests for the presence of the expected workflow files

Feature: Workspace files

    As a researcher,
    I want to make sure that my CWL workflow produces expected files,
    so that I can be sure that the workflow outputs are correct.

    Scenario: The workspace contains the expected input files
        When the workflow is finished
        Then the workspace should include "code/worldpopulation.ipynb"
        And the workspace should include "data/World_historical_and_predicted_populations_in_percentage.csv"

    Scenario: The workflow generates the final plot
        When the workflow is finished
        Then the workspace should contain "outputs/plot.png"
        And the sha256 checksum of the file "outputs/plot.png" should be "ede32c402ca192c338087136b9a9b1081ed914c5afc058d1cd408d806d81a8fc"
        And all the outputs should be included in the workspace

    Scenario: The total workspace size remains within reasonable limits
        When the workflow is finished
        Then the workspace size should be more than 2KiB
        And the workspace size should be less than 200KiB

