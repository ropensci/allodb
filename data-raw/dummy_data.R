# Example cleaning dummy data (see http://r-pkgs.had.co.nz/data.html).

library(dplyr)

dummy_data <- data.frame(var1 = 1:3, var2 = letters[1:3])
# pretend we want to change variable names
dummy_data <- rename(dummy_data, variable1 = var1, variable2 = var2)

# Saves in data/.
use_data(dummy_data, overwrite = TRUE)

# Now document dummy_data in, for example, R/data.R
