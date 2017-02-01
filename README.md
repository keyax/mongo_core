# mongo_core
Mongodb docker container based on ubuntu_core image

[![](https://images.microbadger.com/badges/image/keyax/mongo_core.svg)](https://microbadger.com/images/keyax/mongo_core "Get your own image badge on microbadger.com")   [![](https://images.microbadger.com/badges/version/keyax/mongo_core.svg)](https://microbadger.com/images/keyax/mongo_core "Get your own version badge on microbadger.com")

MongoDB document databases provide high availability and easy scalability.
Full Description
Supported tags and respective Dockerfile links
3.4.1, 3.4, 3, latest (3.4/Dockerfile)
For more information about this image and its history, please see the relevant manifest file (library/mongo). This image is updated via pull requests to the docker-library/official-images GitHub repo.

For detailed information about the virtual/transfer sizes and individual layers of each of the above supported tags, please see the repos/mongo/tag-details.md file in the docker-library/repo-info GitHub repo.

What is MongoDB?
MongoDB (from "humongous") is a cross-platform document-oriented database. Classified as a NoSQL database, MongoDB eschews the traditional table-based relational database structure in favor of JSON-like documents with dynamic schemas (MongoDB calls the format BSON), making the integration of data in certain types of applications easier and faster. Released under a combination of the GNU Affero General Public License and the Apache License, MongoDB is free and open-source software.

First developed by the software company 10gen (now MongoDB Inc.) in October 2007 as a component of a planned platform as a service product, the company shifted to an open source development model in 2009, with 10gen offering commercial support and other services. Since then, MongoDB has been adopted as backend software by a number of major websites and services, including Craigslist, eBay, Foursquare, SourceForge, Viacom, and the New York Times, among others. MongoDB is the most popular NoSQL database system.

wikipedia.org/wiki/MongoDB



How to use this image
start a mongo instance
$ docker run --name some-mongo -d mongo
This image includes EXPOSE 27017 (the mongo port), so standard container linking will make it automatically available to the linked containers (as the following examples illustrate).

connect to it from an application
$ docker run --name some-app --link some-mongo:mongo -d application-that-uses-mongo
... or via mongo
$ docker run -it --link some-mongo:mongo --rm mongo sh -c 'exec mongo "$MONGO_PORT_27017_TCP_ADDR:$MONGO_PORT_27017_TCP_PORT/test"'
Configuration
See the official docs for infomation on using and configuring MongoDB for things like replica sets and sharding.

Just add the --storageEngine argument if you want to use the WiredTiger storage engine in MongoDB 3.0 and above without making a config file. Be sure to check the docs on how to upgrade from older versions.

$ docker run --name some-mongo -d mongo --storageEngine wiredTiger
Authentication and Authorization
MongoDB does not require authentication by default, but it can be configured to do so. For more details about the functionality described here, please see the sections in the official documentation which describe authentication and authorization in more detail.

Start the Database
$ docker run --name some-mongo -d mongo --auth
Add the Initial Admin User
$ docker exec -it some-mongo mongo admin
connecting to: admin
> db.createUser({ user: 'jsmith', pwd: 'some-initial-password', roles: [ { role: "userAdminAnyDatabase", db: "admin" } ] });
Successfully added user: {
    "user" : "jsmith",
    "roles" : [
        {
            "role" : "userAdminAnyDatabase",
            "db" : "admin"
        }
    ]
}
Connect Externally
$ docker run -it --rm --link some-mongo:mongo mongo mongo -u jsmith -p some-initial-password --authenticationDatabase admin some-mongo/some-db
> db.getName();
some-db
Where to Store Data
Important note: There are several ways to store data used by applications that run in Docker containers. We encourage users of the mongo images to familiarize themselves with the options available, including:

Let Docker manage the storage of your database data by writing the database files to disk on the host system using its own internal volume management. This is the default and is easy and fairly transparent to the user. The downside is that the files may be hard to locate for tools and applications that run directly on the host system, i.e. outside containers.
Create a data directory on the host system (outside the container) and mount this to a directory visible from inside the container. This places the database files in a known location on the host system, and makes it easy for tools and applications on the host system to access the files. The downside is that the user needs to make sure that the directory exists, and that e.g. directory permissions and other security mechanisms on the host system are set up correctly.
WARNING (Windows & OS X): The default Docker setup on Windows and OS X uses a VirtualBox VM to host the Docker daemon. Unfortunately, the mechanism VirtualBox uses to share folders between the host system and the Docker container is not compatible with the memory mapped files used by MongoDB (see vbox bug, docs.mongodb.org and related jira.mongodb.org bug). This means that it is not possible to run a MongoDB container with the data directory mapped to the host.

The Docker documentation is a good starting point for understanding the different storage options and variations, and there are multiple blogs and forum postings that discuss and give advice in this area. We will simply show the basic procedure here for the latter option above:

Create a data directory on a suitable volume on your host system, e.g. /my/own/datadir.
Start your mongo container like this:

$ docker run --name some-mongo -v /my/own/datadir:/data/db -d mongo:tag
The -v /my/own/datadir:/data/db part of the command mounts the /my/own/datadir directory from the underlying host system as /data/db inside the container, where MongoDB by default will write its data files.

Note that users on host systems with SELinux enabled may see issues with this. The current workaround is to assign the relevant SELinux policy type to the new data directory so that the container will be allowed to access it:

$ chcon -Rt svirt_sandbox_file_t /my/own/datadir
Image Variants
The mongo images come in many flavors, each designed for a specific use case.

mongo:<version>
This is the defacto image. If you are unsure about what your needs are, you probably want to use this one. It is designed to be used both as a throw away container (mount your source code and start the container to start your app), as well as the base to build other images off of.

Supported Docker versions
This image is officially supported on Docker version 1.13.0.

Support for older versions (down to 1.6) is provided on a best-effort basis.

Please see the Docker installation documentation for details on how to upgrade your Docker daemon.

User Feedback
Issues
If you have any problems with or questions about this image, please contact us through a GitHub issue. If the issue is related to a CVE, please check for a cve-tracker issue on the official-images repository first.

You can also reach many of the official image maintainers via the #docker-library IRC channel on Freenode.

Contributing
You are invited to contribute new features, fixes, or updates, large or small; we are always thrilled to receive pull requests, and do our best to process them as fast as we can.

Before you start to code, we recommend discussing your plans through a GitHub issue, especially for more ambitious contributions. This gives other contributors a chance to point you in the right direction, give you feedback on your design, and help you find out if someone else is working on the same thing.

Documentation
Documentation for this image is stored in the mongo/ directory of the docker-library/docs GitHub repo. Be sure to familiarize yourself with the repository's README.md file before attempting a pull request.
