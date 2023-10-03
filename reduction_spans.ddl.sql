create table reduction_spans (
    entity string,
    year_before_sequence int,
    first_year_in_sequence int,
    last_year_in_sequence int,
    span int,
    observations_in_span int,
    span_has_gaps boolean
);
