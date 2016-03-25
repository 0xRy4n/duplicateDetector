# duplicateDetector
Finds and flags duplicate entries in databases. Makes use of approximate string comparisons and fuzzy logic to catch entries that are not exactly identical, yet similar enough to most likely be duplicates of each other nonetheless.

Currently only exists as an excel macro, which is currently hard-coded to deal with a database that is in the following form:
        Last Name | First Name | Address | Email

This can easily be modified to match any database configuration desired, but if your database / data sheet isn't in that form then don't expect the code to be 'plug and play'- some tweaking is going to be needed.
