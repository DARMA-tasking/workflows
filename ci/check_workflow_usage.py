import json
import os

with open(os.path.dirname(__file__) + "/repositories.json", 'r', encoding="utf-8") as json_file:
  # parse json_data
  repositories = json.loads(json_file.read()) 

repositories = sorted(repositories, key=lambda repo: repo['name'])
for item in repositories:
  print(f"Repository: {item['name']}")

  # TODO