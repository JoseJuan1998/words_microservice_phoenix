# Hangman Words Microservice

First of all start the rabbit_go docker container.

Then go to the `Dockerfile.dev` and change all the `ENV` that contains the IP `192.168.1.194` for your local IP.

To start this Docker container:

  * Run the comand `docker-compose up`

Now you can visit [`localhost:4002/manager/doc`](localhost:4002/manager/doc) from your browser to see the documentation about this API.

To stop this Docker container:

  * CTRL + C
