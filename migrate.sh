#!/bin/bash
# ------------------------------------------------------------------------
# Copyright 2024 WSO2, LLC. (http://wso2.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License


PREVIOUS_APIM_VERSION=4.2.0
MIGRATED_APIM_VERSION=4.3.0
SERVER_HOST=localhost
SERVER_PORT=9444
WSO2_SERVER_HOME=wso2am-4.2.0
WSO2_SERVER_HOME_NEW=wso2am-4.3.0-alpha
MYSQL_CONNECTOR_VERSION=8.0.17
MIGRATION_RES_HOME=apim-migration-resources-1
DB_TYPE=mysql

function log_info(){
    echo "[INFO][$(date '+%Y-%m-%d %H:%M:%S')]: $1"
}

function log_error(){
    echo "[ERROR][$(date '+%Y-%m-%d %H:%M:%S')]: $1"
    exit 1
}

# Function to wait for the server to be up
wait_for_APIM_server() {
    while ! nc -z $SERVER_HOST $SERVER_PORT; do
        log_info "Waiting for the server to be up..."
        sleep 20
    done

    log_info "Server is up. Proceeding with the script."
}

# Migration process
log_info "Starting the migration process..."
docker exec -i mysql-db2 mysql -u root -proot WSO2AM_DB < migration-db-scripts/mysql_script.sql || log_error "Failed to migrate the database." 

# Download WSO2 API Manager 4.3.0
log_info "Downloading WSO2 API Manager 4.3.0..."
# wget https://github.com/chashikajw/aaa/releases/download/t2/wso2am-${MIGRATED_APIM_VERSION}.zip || log_error "Failed to download WSO2 API Manager 4.3.0."

# Extract the downloaded zip file
log_info "Extracting WSO2 API Manager 4.3.0..."
unzip wso2am-${MIGRATED_APIM_VERSION}-alpha.zip || log_error "Failed to extract WSO2 API Manager."

# Replace deployment.toml file
cp conf/apim/430/repository/conf/deployment.toml ${WSO2_SERVER_HOME_NEW}/repository/conf/deployment.toml

# add MySQL JDBC connector to server home as a third party library
cp mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar ${WSO2_SERVER_HOME_NEW}/repository/components/dropins/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar

mv wso2am-4.3.0-alpha wso2am-4.3.0-SNAPSHOT

zip -r wso2am-4.3.0-SNAPSHOT.zip wso2am-4.3.0-SNAPSHOT

# Start the API Manager 4.3.0
log_info "Starting API-Manager 4.3.0..."
# nohup sh wso2am-4.3.0-m2/bin/api-manager.sh &
# sh ${WSO2_SERVER_HOME_NEW}/bin/api-manager.sh

# wait_for_APIM_server


cp wso2am-4.3.0-SNAPSHOT.zip /Users/chashika/Documents/WSO2/repositories/Public/product-apim/modules/distribution/product/target/wso2am-4.3.0-SNAPSHOT.zip

cd /Users/chashika/Documents/WSO2/repositories/Public/product-apim/modules/integration/tests-integration/tests-migration
mvn clean install

docker-compose down