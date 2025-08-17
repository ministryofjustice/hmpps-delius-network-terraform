This module is purely for adding additional sandpit environments such as

delius-core-sandpit-2
delius-core-sandpit-3

etc

only the hosted zones are required to make these environments work for the spg new stack
the extra environments are required due to contention on the regular sandpit environment.


this module is only built with "apply_domains_for_additional_sandpit_environments.Jenkinsfile"

Non used components have been commented out in this file, should other developers wish to use this pattern
and require other modules