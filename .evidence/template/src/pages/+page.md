---
title: Longest Continuous Periods of Lifespan Reduction
---
# Introduction

This page addresses the question "which country has experienced the longest continuous period of reduction in life expectancy?"  Data is from [Life Expectancy](https://ourworldindata.org/life-expectancy).

Since available data includes gaps in dates for some countries and date ranges, the question may have two answers, depending on our defintion.  We analyze in two ways:<br>
1. data that provides an observation for each year in the sequence, in other words one data row per year consecutively
2. data that has gaps in the sequence - for instance observations every 5 years for a period of history

We will address each option.

# Countries with One Observation per Year in Sequence
The top 10 countries that share this misfortune are all in Africa, with Zambia taking the lead.

```sql reduction
select *
from reduction_spans
where span_has_gaps = FALSE
order by span desc
limit 10;
```

<DataTable data={reduction}>
  <Column id="entity"/>
  <Column id="first_year_in_sequence" title='Start' fmt='id'/>
  <Column id="last_year_in_sequence" title='End' fmt='id'/>
  <Column id="span" title="Years"/>
</DataTable>

## Analysis of Zambia's 21 years of Life Expectancy Reduction


### Changes in lifespan in Zambia 1951 - 2020
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

### Comparison between Zambia, the World Average and Average of Neighboring Countries
Zambia's life expectancy tracked slighly above neighboring countries, until the period of continual decline began in 1978.<br>
[Washington Post, 1985 - Zambia Trapped in Poverty's Vise](https://www.washingtonpost.com/archive/politics/1985/09/26/zambia-trapped-in-povertys-vise/2dac22bd-a227-4dad-b4f4-64647d3060a4/)
<LineChart data={comp} x=year y=life_expectancy series=entity yGridlines=false>
  <ReferenceLine x=1985 label="Start of AIDS in Zambia" hideValue=true/>
</LineChart>


### National External Debt of Zambia
Copper is the leading export of Zambia.  At the end of the Vietnam war, the world copper market crashed.  Soon after energy prices began a notable rise.  Since Zambia is a land locked country without rail access to shipping ports, copper exports must be shipped by truck, depending heavily on petroleum.
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

# Countries with Gaps in yearly data
The top 10 countries with gaps in reported data are in more developed areas, with gaps ocurring in earlier time periods.<br>
_Since data has gaps in yearly observations, this table shows the last observation before the first occurrence in the sequence of reductions._

```sql reductions_with_gaps
select *
from reduction_spans
where span_has_gaps = TRUE
and entity <> 'Europe'
order by span desc
limit 10;
```

<DataTable data={reductions_with_gaps}>
  <Column id="entity"/>
  <Column id="year_before_sequence" title='Observation Before Start' fmt='id'/>
  <Column id="last_year_in_sequence" title='End' fmt='id'/>
  <Column id="span" title="Years"/>
</DataTable>

## Analysis of Bangladesh's Estimated 30 years of Life Expectancy Reduction

### Changes in lifespan in Bangladesh, 1876 - 1950
Life expectancy in Bangladesh was dismally low in the late 19th and early 20th centuries.  British Raj rule hit what was then called Bengal particularly hard.<br>
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
Fortunately, Bangladesh's life expectancy rose to world averages in the second half of the 20th century.
<LineChart data={bangladesh_recent} y=life_expectancy x=year series=entity>
  <ReferenceLine x=1971 label="War of Independence" hideValue=true/>
</LineChart>
