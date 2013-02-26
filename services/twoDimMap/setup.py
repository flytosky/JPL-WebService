from setuptools import setup, find_packages

setup(
    name='twoDimMap',
    version='1.0',
    long_description='Two Dimensional Map',
    packages=find_packages(),
    include_package_data=True,
    zip_safe=False,
    install_requires=['Flask', 'gunicorn', 'tornado',
                      'httplib2', 'lxml']
)