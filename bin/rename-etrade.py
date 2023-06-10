#!/usr/bin/env python3

import os
import re

pattern = re.compile(r'Brokerage Statement.*(\d{6})\.pdf$')
files = [f for f in os.listdir('.') if os.path.isfile(f)]
for f in files:
    match = pattern.match(f)
    if match:
        digits = match.group(1)
        new_name = digits[:4] + "-" + digits[4:6] + "-01-etrade.pdf"
        os.rename(f, new_name)
        print(f"Renamed {f} to {new_name}")