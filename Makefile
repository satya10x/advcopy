EXTENSION = advcopy        # the extensions name
DATA = advcopy--0.0.2.sql  # script files to install

# postgres build stuff
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
