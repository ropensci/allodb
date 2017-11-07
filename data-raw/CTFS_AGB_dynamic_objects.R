# Use data from  Ervan Rutishauser <er.rutishauser@gmail.com> received on Sat,
# Oct 28, 2017 at 4:05 AM, via CTFS_AGB_dynamic_objects.Rdata

ficus <- as_tibble(ficus)
site.info <- as_tibble(site.info)
WSG <- as_tibble(WSG)
use_data(
  ficus,
  site.info,
  WSG,
  overwrite = TRUE
)

