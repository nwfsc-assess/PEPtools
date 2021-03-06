% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/solve_numbers.R
\name{solve_numbers}
\alias{solve_numbers}
\title{Function to solve out numbers of fish in the forecast to equal
match management ABC values. If a fleet in your model has removals
specified as numbers of fish (1,000s), SS will expect numbers of fish
to be used in the forecast file for that fleet is there are pre-specified
forecast removals.  This creates challenges when attempting to determine the
right number of fish that will meet the harvest specified ABC values. This 
function does a bisection approach to iteratively determine the number of fish
that will match the fleet specified removals in terms of biomass.}
\usage{
solve_numbers(mod_dir, fore_yrs, fleet_abc, fleet = NULL)
}
\arguments{
\item{mod_dir}{the directory of your model - all runs will be conducted in this folder
make sure you are alright if the SS files are changed.}

\item{fore_yrs}{a vector of forecast years where removals are pre-specified}

\item{fleet_abc}{a vector of fleet specific abc values for the fleet that is currently
in terms of numbers of fish.}

\item{fleet}{fleet number within SS of the fleet that has removals in terms of numbers of
fish.}
}
\description{
Function to solve out numbers of fish in the forecast to equal
match management ABC values. If a fleet in your model has removals
specified as numbers of fish (1,000s), SS will expect numbers of fish
to be used in the forecast file for that fleet is there are pre-specified
forecast removals.  This creates challenges when attempting to determine the
right number of fish that will meet the harvest specified ABC values. This 
function does a bisection approach to iteratively determine the number of fish
that will match the fleet specified removals in terms of biomass.
}
