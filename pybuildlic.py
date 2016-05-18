#!/usr/bin/env python
# -*- coding: utf-8 -*-

import time
from mxpsu import time2stamp
from optparse import OptionParser
import lic

if __name__ == "__main__":
    usage = "usage: %prog [options]"
    parser = OptionParser(usage=usage)
    parser.add_option("-d", "--deadline", dest="deadline",
                      help="Use format yyyy", metavar="Datetime")
    parser.add_option("-c", "--maxclient", dest="maxclient", default=2100,
                      type="int", help="Max number of data client can be connect", metavar="number")

    (options, args) = parser.parse_args()

    dl = ""
    if options.deadline is None:
        # print(parser.print_help())
        y = int(time.localtime()[0]) + 1
    else:
        y = int(options.deadline)

    lic.generate_license(deadline_year=y, max_client=options.maxclient)
