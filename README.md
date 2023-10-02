# Life Expectancy homework

## Files
### Longest Continuous Periods of Lifespan Reduction.pdf
Export of the dashboard created.

### life_expectancy_analysis.xlsx
Simple workbook used in data profiling and results testing.

### lifespan081.duckdb
#### Tables

##### Life_expectancy
original data table

##### reduction_spans
This table addresses the "longest sequence of life expectancy reductions" assignment.  The table is created by the ddl sql noted below, and populated by the dml sql noted below.  Note that only one top longest sequence of reductions is included per entity.  In other words if an entity has sequences of reduction with and without gaps, only the longest is included.

Columns:
* entity - same entity as original table               
* first_year_in_sequence - first year in longest sequence of decline
* last_year_in_sequence - last year in longest sequence of decline
* span - number of years in longest sequence of decline                 
* observations_in_span - count of observations in sequence
* span_has_gaps - TRUE if sequence has gaps in years (e.g. one observation per 5 years)       

##### contiguous_decline_ranking_by_entity
A ranking of entities by numer of contiguous (no gaps) sequences of reduction years.  This was not used in the dashboard.

##### reduction_spans.ddl.sql
creates the reduction_spans table in DuckDb.

##### reduction_spans.dml.sql
Populates the reduction_spans table with a very long sequence of CTEs built into a single query.

### Evidence Contents
evidence.plugins.yaml
node_modules - folder
package-lock.json
package.json
pages - folder

# Data Profiling
Data profiling was done via SQL queries and visual review of data in Excel.  Findings:<br>
* Table includes both countries and regions/groups.  Other that Western Sahara and World, all regions/groups have a null code column.  If required, a country codes CSV could have been imported to distinguish countries vs regions/groups.
* Some entities have full consecutive years, and some have gaps.  Older data tends to have more gaps.
* Roughly 20K rows of data are included.


# Testing
Verification was done with a simple Excel workbook noted in this README, and included in this repository.   


# Duck db notes
How to convert duckdb versions
https://stackoverflow.com/questions/75712317/import-and-export-in-duckdb-due-to-change-of-version

Url to spoof to download different duckdb versions
https://github.com/duckdb/duckdb/releases/download/v0.7.1/duckdb_cli-osx-universal.zip
