@slow_process
Feature: Test product activation

  Scenario: System registration
    Given I have a system with activated base product

    Then a file named "/etc/zypp/credentials.d/SCCcredentials" should exist
    And the file "/etc/zypp/credentials.d/SCCcredentials" should contain "SCC_"

    And zypp credentials for base should exist
    And zypp credentials for base should contain "SCC_"

    And zypper should contain a service for base product
    And zypper should contain the repositories for base product


  Scenario: System de-registration
    When I deregister the system
    Then a file named "/etc/zypp/credentials.d/SCCcredentials" should not exist

    # This needs to match _SP1_, _SP2
    And zypp credentials for base should not exist
    And zypp credentials for sdk should not exist
    And zypp credentials for wsm should not exist

    And I run `zypper lr`
    And the output should not contain "SUSE_Linux_Enterprise_Server_12_x86_64"
    And the output should not contain "SUSE_Linux_Enterprise_Software_Development_Kit_12_x86_64"
    And the output should not contain "Web_and_Scripting_Module_12_x86_64"


  Scenario: Error cleanly if system record was deleted on SCC only
    When I call SUSEConnect with '--regcode VALID' arguments
    Then I delete the system on SCC

    And I call SUSEConnect with '--status true' arguments
    Then the exit status should be 67
    And the output should contain:
    """
    Invalid system credentials, probably because the registered system was deleted in SUSE Customer Center.
    """


  Scenario: System cleanup
    Then a file named "/etc/zypp/credentials.d/SCCcredentials" should exist
    And zypp credentials for base should exist

    And I run `zypper lr`
    And zypper should contain the repositories for base product

    When I call SUSEConnect with '--cleanup true' arguments

    Then a file named "/etc/zypp/credentials.d/SCCcredentials" should not exist
    And zypp credentials for base should not exist


  Scenario: Remove all registration leftovers
    When System cleanup
