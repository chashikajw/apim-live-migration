
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
WSO2_SERVER_HOME_NEW=wso2am-4.3.0-m2
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
        sleep 10
    done

    log_info "Server is up. Proceeding with the script."
}


log_info "Starting docker-compose..."
docker-compose up -d || log_error "Failed to start docker-compose."

# Download WSO2 API Manager 4.2.0
log_info "Downloading WSO2 API Manager 4.2.0..."
# wget https://github.com/chashikajw/aaa/releases/download/t2/wso2am-${PREVIOUS_APIM_VERSION}.zip || log_error "Failed to download WSO2 API Manager."

# Extract the downloaded zip file
log_info "Extracting WSO2 API Manager 4.2.0..."
unzip wso2am-${PREVIOUS_APIM_VERSION}.zip || log_error "Failed to extract WSO2 API Manager."


log_info "Downloading MySQL JDBC connector..."
wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/${MYSQL_CONNECTOR_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar || log_error "Failed to download MySQL JDBC connector."

# add MySQL JDBC connector to server home as a third party library
cp mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar ${WSO2_SERVER_HOME}/repository/components/dropins/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar

# Replace deployment.toml file
cp conf/apim/420/repository/conf/deployment.toml ${WSO2_SERVER_HOME}/repository/conf/deployment.toml

# Stat the API Manager
log_info "Starting API-Manager..."
nohup sh wso2am-4.2.0/bin/api-manager.sh &



# Populate the data
git clone https://github.com/tharikaGitHub/apim-migration-resources-1.git


cp jmeter-scripts/tenant-creation/apim-4.2.0-data-populating-tenant-creation-plan.jmx ${MIGRATION_RES_HOME}/apim-data-populator/apim-4.2.0-data-populating-tenant-creation-plan.jmx
cp jmeter-scripts/data/apim-4.2.0-data-populating-migration-plan.jmx ${MIGRATION_RES_HOME}/apim-data-populator/apim-4.2.0-data-populating-migration-plan.jmx

# Download Apache JMeter
# log_info "Downloading Apache JMeter..."
# wget "https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-5.5.tgz" || log_error "Failed to download Apache JMeter."

# Extract Apache JMeter
tar -xf apache-jmeter-5.5.tgz || log_error "Failed to extract Apache JMeter."

wait_for_APIM_server

./apache-jmeter-5.5/bin/jmeter -n -t ${MIGRATION_RES_HOME}/apim-data-populator/apim-4.2.0-data-populating-tenant-creation-plan.jmx -l ${MIGRATION_RES_HOME}/apim-data-populator/apim-4.2.0-data-populating-tenant-creation-plan.jtl

log_info "Restarting the API Manager 4.2.0..."
sh wso2am-4.2.0/bin/api-manager.sh restart

wait_for_APIM_server

./apache-jmeter-5.5/bin/jmeter -n -t ${MIGRATION_RES_HOME}/apim-data-populator/apim-4.2.0-data-populating-migration-plan.jmx -l ${MIGRATION_RES_HOME}/apim-data-populator/apim-4.2.0-data-populating-migration-plan.jtl

log_info "Stopping the API Manager 4.2.0..."
sh wso2am-4.2.0/bin/api-manager.sh stop
