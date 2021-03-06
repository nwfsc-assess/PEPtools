#' Function to solve out numbers of fish in the forecast to equal
#' match management ABC values. If a fleet in your model has removals
#' specified as numbers of fish (1,000s), SS will expect numbers of fish
#' to be used in the forecast file for that fleet is there are pre-specified
#' forecast removals.  This creates challenges when attempting to determine the
#' right number of fish that will meet the harvest specified ABC values. This 
#' function does a bisection approach to iteratively determine the number of fish
#' that will match the fleet specified removals in terms of biomass.
#'
#' @param mod_dir the directory of your model - all runs will be conducted in this folder
#' make sure you are alright if the SS files are changed.
#' @param fore_yrs a vector of forecast years where removals are pre-specified
#' @param fleet_abc a vector of fleet specific abc values for the fleet that is currently
#' in terms of numbers of fish. 
#' @param fleet fleet number within SS of the fleet that has removals in terms of numbers of
#' fish.
#'
#'
#'
solve_numbers <- function(mod_dir, fore_yrs, fleet_abc, fleet = NULL){
	# Set the wd to run the model
	setwd(mod_dir)

	if(!file.exists("ss.par")){		
		stop("There is no par file in mod_dir. Please run the model.")
	}

	if(length(fore_yrs) != length(fleet_abc)) {
		stop("The length of fore_yrs and fleet_abc need to be the same.")
	}

	yrs = fore_yrs
	abc = fleet_abc

	if(is.null(fleet)){
		dat = r4ss::SS_readdat("data.ss_new")
		fleet = which(dat$fleetinfo$units == 2)

		if(length(fleet) > 1){		
		stop("There appears to be more than one fleet with catches in numbers. \n
			  Function currently only does one fleet at a time.  \n
			  Specify the fleet input in the function to specify which fleet to do.")
		}
	}

	# Turn max phase to 0 and read from par file
	starter = r4ss::SS_readstarter(file.path(mod_dir, "starter.ss"))
	use_par = starter$init_values_src 
	starter$init_values_src = 1
	max_phase = starter$last_estimation_phase
	starter$last_estimation_phase = 0
	r4ss::SS_writestarter(starter, dir = mod_dir, overwrite = TRUE, verbose = FALSE)

	for(i in 1:length(yrs)){
		# Start from the previous solution assuming abc's are similar
		if(i > 1){
			fore = r4ss::SS_readforecast(file.path(mod_dir, "forecast.ss"), verbose = FALSE)
			fish = fore$ForeCatch[, "Catch or F"]
			fore$ForeCatch[i, "Catch or F"] = fish[1] * abc[1]/abc[2]
			r4ss::SS_writeforecast(fore, dir = mod_dir, overwrite = TRUE)
		}

		for (a in 1:50){

			if (a == 1){
				rep = r4ss::SS_output(mod_dir, verbose = FALSE, printstats = FALSE)
				bio = rep$timeseries[rep$timeseries$Yr == yrs[i], paste0("dead(B):_", fleet)]
			}
	
			fore = r4ss::SS_readforecast(file.path(mod_dir, "forecast.ss"), verbose = FALSE)
			fish = fore$ForeCatch[i, "Catch or F"]

			if(bio < abc[i]){
				step = ifelse( bio/abc[i] >= 0.5, 0.4*fish, 
					   ifelse( bio/abc[i] > 0.5 & bio/abc[i] <= 0.2, 0.2*fish, 
					   ifelse( bio/abc[i] > 0.2 & bio/abc[i] <= 0.1, 0.10*fish,
					   ifelse( bio/abc[i] > 1.1 & bio/abc[i] <= 1.05, 0.05*fish,
					   ifelse( bio/abc[i] > 1.05 & bio/abc[i] < 1.01, 0.01*fish,
					   	0.001*fish)))))
				new_value = fish + step
			} else {
				step = ifelse( bio/abc[i] >= 5, 0.4*fish, 
					   ifelse( bio/abc[i] < 5 & bio/abc[i] >= 2, 0.2*fish, 
					   ifelse( bio/abc[i] < 2 & bio/abc[i] >= 1.1, 0.10*fish,
					   ifelse( bio/abc[i] < 1.1 & bio/abc[i] >= 1.05, 0.05*fish,
					   ifelse( bio/abc[i] < 1.05 & bio/abc[i] > 1.01, 0.01*fish,
					   	0.001*fish)))))
				new_value = fish - step
			}
			
			# Write out the new fish value to the forecast file
			fore$ForeCatch[i, "Catch or F"] = new_value
			r4ss::SS_writeforecast(fore, dir = mod_dir, overwrite = TRUE)
	
			shell("ss -nohess -maxfun 0 > output.txt 2>&1")
	
			rep = r4ss::SS_output(mod_dir, covar = FALSE, verbose = FALSE, printstats = FALSE)
			bio = rep$timeseries[rep$timeseries$Yr == yrs[i], paste0("dead(B):_", fleet)]

			print(paste0("!!!!!!!!!!!!!!!!! Biomass = ", bio, " ABC = ", abc[i], "!!!!!!!!!!!!!!!!"))
			if (bio/abc[i] > 0.99 & bio/abc[i] < 1.01){
				print("Found solution")
				break()
			}
		} # a loop
	}

	# Change the max phase back to the original value
	starter = r4ss::SS_readstarter(file.path(mod_dir, "starter.ss"))
	starter$init_values_src = use_par
	starter$last_estimation_phase = max_phase
	r4ss::SS_writestarter(starter, dir = mod_dir, overwrite = TRUE, verbose = FALSE)


}
