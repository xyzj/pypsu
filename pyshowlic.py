#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
from optparse import OptionParser
import mxlic as lic


if __name__ == "__main__":
    usage = "usage: %prog [options]"
    parser = OptionParser(usage=usage)
    parser.add_option("-d", "--do", dest="do", default="s",
                      help="show(s) or repair(r) the license file.")
    parser.add_option("-f", "--licfile", dest="licfile", default="LICENSE",
                      help="the license file name")
    # parser.add_option("-r", "--repair", dest="repair",
    # help="repair bad licese file.")

    (options, args) = parser.parse_args()

    lf = options.licfile
    # lic = []
    # lic = open(lf, "rU").readlines()
    # s = ""
    # for l in lic:
    #     if l.startswith("–" * 10) or l.strip() == "":
    #         continue
    #     s += l.strip()
    # print("o:" + s)
    # dlic = Lic()
    # dlic.destroy_license(s)

    if options.do == "r":
        lic = []
        lic = open(lf, "rU").readlines()
        s = ""
        for l in lic:
            if l.startswith("–" * 10) or l.strip() == "":
                continue
            s += l.strip()
        print("d:" + s)
        l = len(s)
        n = int(s[l - 3:l - 2])
        c = int(s[l - 3 - n: l - 3])
        s = "{0}{1}{2}".format(s[:c], s[c + 1:l - 3 - n], s[l - 2:])
        print("r:" + s)
        l = len(s)
        lic = ["–" * 7 + "BEGIN LICENSE" + "–" * 7]
        lic.extend([s[i: i + 27] for i in range(0, l, 27)])
        lic.append("–" * 8 + "END LICENSE" + "–" * 8)
        with open("{0}.fix".format(lf), "w") as f:
            try:
                f.writelines([d + "\n" for d in lic])
            except:
                pass

    s = lic.load_license()
    # mlic = License()
    # mlic.ParseFromString(base64.b64decode(s))
    print(s)
