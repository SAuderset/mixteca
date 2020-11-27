from setuptools import setup, find_packages
import json


with open("metadata.json") as fp:
    metadata = json.load(fp)


setup(
    name="lexibank_mixteca",
    version="1.2.0",
    description=metadata["title"],
    license=metadata.get("license", ""),
    url=metadata.get("url", ""),
    py_modules=["lexibank_mixteca"],
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    include_package_data=True,
    zip_safe=False,
    entry_points={"lexibank.dataset": ["mixteca=lexibank_mixteca:Dataset"]},
    install_requires=["pylexibank>=2.1"],
)
