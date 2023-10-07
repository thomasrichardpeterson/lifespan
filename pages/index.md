---
title: Longest Uninterrupted Durations of Life Expectancy Decrease
---

# Introduction

This page explores the query: "Which nation has undergone the lengthiest unbroken stretch of declining life expectancy?" <br>
The data source for this analysis: [Life Expectancy](https://ourworldindata.org/).

Given that the available data may exhibit discontinuities in time intervals for certain countries and date ranges, the question can yield two distinct answers, contingent upon our specific definition. We approach the analysis in two distinct manners:

1. When dealing with data that furnishes an observation for each year in a continuous sequence, where each data entry corresponds to one year in succession.
2. When handling data characterized by gaps in the sequence—for example, observations made every 5 years over a historical period.


# Nations with a Single Observation Per Year in Sequential Order
All of the ten countries facing this unfortunate trend are located in Africa, and Zambia leads the list.

```sql reduction
select *
from reduction_spans
where span_has_gaps = FALSE
order by span desc
limit 10;
```

<DataTable data={reduction}>
  <Column id="entity" title='Country'/>
  <Column id="first_year_in_sequence" title='Start' fmt='id'/>
  <Column id="last_year_in_sequence" title='End' fmt='id'/>
  <Column id="span" title="Years"/>
</DataTable>


<Details title="Examination of Zambia's Two-Decade Life Expectancy Decline">

### Fluctuations in Life Expectancy in Zambia from 1951 to 2020
```sql zambia
select newer.year, 
  newer.life_expectancy,
  newer.life_expectancy - older.life_expectancy as change
from life_expectancy newer
join life_expectancy older on newer.entity = older.entity and newer.year = older.year + 1
where newer.entity = 'Zambia'
;
```

<BarChart data={zambia} y=change x=year  yAxisLabels=false>
  <ReferenceArea xMin=1978 xMax=1998 label="21 Years Decline"/>
</BarChart>


```sql comp
select year, 
        entity, 
        life_expectancy     
from life_expectancy 
where entity in ('Zambia', 'World')
and year between 1970 and 2000

union
select year, 
        'Neighboring Countries', 
        avg(life_expectancy) as life_expectancy    
from life_expectancy 
where entity in ('Congo', 'Tanzania', 'Malawi', 'Mozambique', 'Zimbabwe', 'Botswana', 'Namibia', 'Angola')
and year between 1970 and 2000
group by year
order by year;
```

### Comparison of Life Expectancy: Zambia vs. Global Average and Neighboring Countries' Average
Zambia's life expectancy consistently outpaced that of its neighboring countries until the onset of a sustained decline in 1978.<br>
[Washington Post, 1985 - Zambia Trapped in Poverty's Vise](https://www.washingtonpost.com/archive/politics/1985/09/26/zambia-trapped-in-povertys-vise/2dac22bd-a227-4dad-b4f4-64647d3060a4/)
<LineChart data={comp} x=year y=life_expectancy series=entity xTitle='Country' yGridlines=false>
  <ReferenceLine x=1985 label="Start of AIDS in Zambia" hideValue=true/>
</LineChart>


### Zambia's National External Debt

Copper stands as Zambia's primary export commodity. Following the conclusion of the Vietnam War, the global copper market experienced a significant downturn. Shortly thereafter, energy prices embarked on a notable upward trajectory. Zambia, being a landlocked nation without direct railway access to seaports, relies heavily on the transportation of copper exports via trucks, which, in turn, depend significantly on petroleum.
```sql debt
select 2001 as year, 6189776538 as debt union
select 2000, 	5811480208 union
select 1999, 	5953049691 union
select 1998, 	6870434147 union
select 1997, 	6659848622 union
select 1996, 	7060056954 union
select 1995, 	6957808472 union
select 1994, 	6808521301 union
select 1993, 	6477914988 union
select 1992, 	6700065956 union
select 1991, 	6958488380 union
select 1990, 	6904814239 union
select 1989, 	6553433177 union
select 1988, 	6694151925 union
select 1987, 	6480343008 union
select 1986, 	5633318266 union
select 1985, 	4487171832 union
select 1984, 	3751427553 union
select 1983, 	3745387538 union
select 1982, 	3662594056 union
select 1981, 	3609972787 union
select 1980, 	3252576759 union
select 1979, 	3039848240 union
select 1978, 	2578001425 union
select 1977, 	2336027269 union
select 1976, 	1893531434 union
select 1975, 	1681371684 union
select 1974, 	1196332640 union
select 1973, 	1030648296 union
select 1972, 	 943514892 union
select 1971, 	 857443206 union
select 1970, 	 813521836 
;
```

<LineChart data={debt}  x=year y=debt yGridlines=false>
  <ReferenceLine x=1974 label="-38% Copper" hideValue=true/>
  <ReferenceLine x=1979 label="+102% Oil" hideValue=true/>
</LineChart>
</Details>

# Nations with Discontinuous Yearly Data
The top ten countries exhibiting data gaps tend to be situated in more developed regions, and these data discontinuities typically occur in earlier historical periods. Bangladesh leads the list.<br><br>
_As there are gaps in the yearly observations in the data, this table displays the final recorded observation year preceding the initial occurrence in the sequence of declines._
```sql reductions_with_gaps
select *
from reduction_spans
where span_has_gaps = TRUE
and entity <> 'Europe'
order by span desc
limit 10;
```
<DataTable data={reductions_with_gaps}>
  <Column id="entity" title='Country'/>
  <Column id="year_before_sequence" title='Year Preceding' fmt='id'/>
  <Column id="last_year_in_sequence" title='Last Year in Sequence' fmt='id'/>
  <Column id="span" title="Years"/>
</DataTable>

<Details title="Analysis of Bangladesh's Estimated 30 years of Life Expectancy Reduction">
Life expectancy in Bangladesh experienced a distressingly low period during the late 19th and early 20th centuries. This challenging situation was exacerbated by the impact of British Raj rule, particularly affecting the region then known as Bengal.<br>
[The Bengal Famine](https://yourstory.com/2014/08/bengal-famine-genocide)

```sql bangladesh
select year,
  life_expectancy
from life_expectancy 
where entity = 'Bangladesh'
and year between 1876 and 1926
;
```

<DataTable data={bangladesh}>
  <Column id="year" fmt='id'/>
  <Column id="life_expectancy"/>
</DataTable>

### Changes in lifespan in Bangladesh, 1876 - 1950
<LineChart data={bangladesh} y=life_expectancy x=year>
  <ReferenceLine x=1873 label="1873 Bengal Famine" hideValue=true/>
  <ReferenceLine x=1892 label="1892 Bengal Famine" hideValue=true/>
  <ReferenceLine x=1897 label="1897 Bengal Famine" hideValue=true/>
</LineChart>

```sql bangladesh_recent
select 
  entity,
  year,
  life_expectancy
from life_expectancy 
where entity in ('Bangladesh', 'World')
and year >= 1950
;
```
Thankfully, Bangladesh's life expectancy ascended to align with global averages during the latter half of the 20th century.
<LineChart data={bangladesh_recent} y=life_expectancy x=year series=entity>
  <ReferenceLine x=1971 label="War of Independence" hideValue=true/>
</LineChart>

</Details>