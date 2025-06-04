# Setup for openEHR bootcamp exercise applications


## EHRbase setup (optional, since you can use the Medblocks EHRBase server)

EHRbase is a Postgres server to work with openEHR.

If you want to use your own EHRbase server, you can use the official docker image.
- Install the EHRBase docker image
- Get docker-compose.yaml & init.sql. The ones in this repo, were retrieved from Medblocks (https://github.com/medblocks/openehr-bootcamp)
- ```docker-compose up ```
    - If docker-compose is not installed, install docker desktop
        - If it's still not working and you're on mac, use these commands to fix it:   
        ```sudo rm /usr/local/bin/docker-compose```  
        ```sudo ln -s /Applications/Docker.app/Contents/Resources/cli-plugins/docker-compose /usr/local/bin/docker-compose```
- To test if EHRbase is up and running, use a browser and navigate to http://localhost:8080/ehrbase/ or http://localhost:8080/ehrbase/swagger-ui/index.html
- To delete all the data from the local EHRBase server, run ```docker-compose down -v```, then ```docker-compose up``` again.

## Apps as part of the practical learning of openEHR

### Form & Compositions App
This web app uses an openEHR template which I created with the Archetype Designer (https://tools.openehr.org/designer/). The content of the template is in this case not the focus. The focus of this app is the demonstration of the template as a web form to create instances of it, called compositions. With the app you can create, edit and delete compositions by using the EHRBase REST API on a Medblocks server.

To install all the necessary node packages:
```sh
cd bootcamp-exercises/openehr-form-compositions-app
```
Then run:
```sh
npm install
```
To run the web app:
```sh
npm run dev
```

### Data Charting with AQL App
This web app uses AQL (Archetype Query Language) to query the EHRbase server for data and displays it in a chart. With AQL, data points from across multiple templates can be queried and displayed together. The app uses the EHRBase REST API on a Medblocks server.

To install all the necessary node packages:
```sh
cd bootcamp-exercises/openehr-data-charting-aql-app
```
Then run:
```sh
npm install
```
To run the web app:
```sh
npm run dev