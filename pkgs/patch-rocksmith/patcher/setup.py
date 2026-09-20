from setuptools import setup

setup(
    name="patch-rocksmith",
    version="1.0.0",
    description="Patch a Steam game with RS_ASIO/PipeASIO",
    py_modules=["main"],
    install_requires=[
        "protontricks",
    ],
    entry_points={
        "console_scripts": [
            "patch-rocksmith=main:main",
        ],
    },
)
