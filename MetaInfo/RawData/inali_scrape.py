import csv
import requests
from urllib.request import urlopen
from bs4 import BeautifulSoup

url = "http://www.inali.gob.mx/clin-inali/html/v_mixteco.html#1"
html = requests.get(url, verify=False).text
soup = BeautifulSoup(html, "html.parser")
table = soup.findAll("table", {"class":"table table-responsive"})[0]
rows = table.findAll("tr")

with open("inali_scraped.csv", "wt+", newline="") as f:
    writer = csv.writer(f)
    for row in rows:
        csv_row = []
        for cell in row.findAll(["td", "th"]):
            csv_row.append(cell.get_text())
        writer.writerow(csv_row)
