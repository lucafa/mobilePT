import plistlib
import sys

with open("Info.plist", "rb") as f:
    plist = plistlib.load(f)
    print(plist)
