#!/usr/bin/env python3
import json, sys, time, urllib.parse, urllib.request

dois = [
    "10.1371/journal.pone.0082491",
    "10.1007/s00779-023-01720-5",
    "10.1111/cgf.15114",
    "10.1007/s12193-019-00317-8",
    "10.1109/taslp.2014.2367821",
    "10.1016/s0960-0779(99)00137-x",
    "10.1613/jair.3908",
    "10.1145/3136755.3136783",
    "10.3389/fnins.2022.930944",
    "10.1155/2013/371374",
    "10.1162/comj_a_00358",
    "10.1162/comj_a_00580",
    "10.21785/icad2021.033",
    "10.21785/icad2018.006",
    "10.21785/icad2019.069",
]
rows = []
for doi in dois:
    url = "https://api.crossref.org/works/" + urllib.parse.quote(doi, safe="")
    try:
        with urllib.request.urlopen(url, timeout=20) as r:
            msg = json.load(r)["message"]
        rows.append({
            "doi": doi,
            "title": (msg.get("title") or [""])[0],
            "container": (msg.get("container-title") or [""])[0],
            "year": (((msg.get("published-print") or msg.get("published-online") or msg.get("issued") or {}).get("date-parts") or [[None]])[0][0]),
            "type": msg.get("type"),
            "url": msg.get("URL"),
        })
    except Exception as e:
        rows.append({"doi": doi, "error": str(e)})
    time.sleep(0.2)
print(json.dumps(rows, indent=2, ensure_ascii=False))
