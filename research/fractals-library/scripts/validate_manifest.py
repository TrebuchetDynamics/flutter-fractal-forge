#!/usr/bin/env python3
import json
import sys
from pathlib import Path

p = Path(__file__).resolve().parents[1] / 'data' / 'fractal_manifest.json'
with open(p) as f: m=json.load(f)
ids=[x['id'] for x in m]
if len(ids)!=200: print('Expected 200, got',len(ids)); sys.exit(1)
if len(ids)!=len(set(ids)): print('Duplicate IDs'); sys.exit(1)
print('OK: manifest has 200 unique IDs')
