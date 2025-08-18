# Tests for the presence of the expected workflow files

Feature: Workspace files

    As a researcher,
    I want to make sure that my serial workflow produces expected files,
    so that I can be sure that the workflow outputs are correct.

    Scenario: The workspace contains the expected input files
        When the workflow is finished
        Then the workspace should include "code/worldpopulation.ipynb"
        And the workspace should include "data/World_historical_and_predicted_populations_in_percentage.csv"

    Scenario: The workflow generates the final plot
        When the workflow is finished
        Then the workspace should contain "results/plot.png"
        And the sha256 checksum of the file "results/plot.png" should be "32a45b2bab456916da0bfaa9f399237680407f1342033e10571d1fbcf2f6ced8"
        And all the outputs should be included in the workspace

    Scenario: The total workspace size remains within reasonable limits
        When the workflow is finished
        Then the workspace size should be more than 20KiB
        And the workspace size should be less than 85KiB
