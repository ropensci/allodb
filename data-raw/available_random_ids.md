The file data-raw/available_random_ids.csv contains random ids that you can use to identify new equations. Every time you use an id from this list, you should remove it from this list.

This chunk shows how the random ids were created.

```
# WARNING
# This chunk should not be re-run. If you re-run it, you will change the random
# ids. 
available_ids <- tibble::tibble(random_id = ids::random_id(2000, bytes = 3))
write_csv(available_ids, here("data-raw/available_random_ids.csv"))
```
