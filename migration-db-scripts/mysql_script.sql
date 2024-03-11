-- Alter Tables –

ALTER TABLE AM_API_URL_MAPPING
ADD LOG_LEVEL VARCHAR(255) DEFAULT 'OFF';

ALTER TABLE AM_POLICY_APPLICATION
ADD RATE_LIMIT_COUNT INT(11) NULL DEFAULT 0,
ADD RATE_LIMIT_TIME_UNIT VARCHAR(25) NULL DEFAULT NULL;

ALTER TABLE AM_DEPLOYMENT_REVISION_MAPPING
ADD REVISION_STATUS VARCHAR(255) NULL DEFAULT 'APPROVED';


ALTER TABLE AM_GATEWAY_ENVIRONMENT
ADD TYPE VARCHAR(255) NULL DEFAULT 'hybrid',
ADD GATEWAY_TYPE VARCHAR(255) NOT NULL DEFAULT 'Regular';


-- Add New Tables –

CREATE TABLE IF NOT EXISTS AM_KEY_MANAGER_PERMISSIONS (
  KEY_MANAGER_UUID VARCHAR(50) NOT NULL,
  PERMISSIONS_TYPE VARCHAR(50) NOT NULL,
  ROLE VARCHAR(255),
  PRIMARY KEY (KEY_MANAGER_UUID, ROLE),
  FOREIGN KEY (KEY_MANAGER_UUID) REFERENCES AM_KEY_MANAGER(UUID) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS AM_GATEWAY_POLICY_METADATA (
    GLOBAL_POLICY_MAPPING_UUID VARCHAR(45)   NOT NULL,
    DISPLAY_NAME               VARCHAR(255)  NULL,
    DESCRIPTION                VARCHAR(1023) NULL,
    ORGANIZATION               VARCHAR(100)  NOT NULL,
    PRIMARY KEY (GLOBAL_POLICY_MAPPING_UUID)
)ENGINE INNODB;


CREATE TABLE IF NOT EXISTS AM_GATEWAY_POLICY_MAPPING (
    POLICY_TO_FLOW_INFO_MAPPING_ID INTEGER AUTO_INCREMENT,
    GLOBAL_POLICY_MAPPING_UUID     VARCHAR(45)   NOT NULL,
    POLICY_UUID                    VARCHAR(45)   NOT NULL,
    POLICY_ORDER                   INTEGER       NOT NULL,
    DIRECTION                      VARCHAR(10)   NOT NULL,
    PARAMETERS                     VARCHAR(1024) NOT NULL,
    FOREIGN KEY (POLICY_UUID) REFERENCES AM_OPERATION_POLICY (POLICY_UUID) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (GLOBAL_POLICY_MAPPING_UUID) REFERENCES AM_GATEWAY_POLICY_METADATA (GLOBAL_POLICY_MAPPING_UUID) ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (POLICY_TO_FLOW_INFO_MAPPING_ID)
)ENGINE INNODB;


CREATE TABLE IF NOT EXISTS AM_GATEWAY_POLICY_DEPLOYMENT (
    GATEWAY_LABEL              VARCHAR(255) NOT NULL,
    GLOBAL_POLICY_MAPPING_UUID VARCHAR(45)  NOT NULL,
    ORGANIZATION               VARCHAR(100) NOT NULL,
    FOREIGN KEY (GLOBAL_POLICY_MAPPING_UUID) REFERENCES AM_GATEWAY_POLICY_METADATA (GLOBAL_POLICY_MAPPING_UUID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (ORGANIZATION,GATEWAY_LABEL)
)ENGINE INNODB;




CREATE TABLE IF NOT EXISTS AM_APP_REVOKED_EVENT (
    CONSUMER_KEY    VARCHAR(255)    NOT NULL,
    TIME_REVOKED    TIMESTAMP       NOT NULL,
    ORGANIZATION    VARCHAR(100),
    PRIMARY KEY (CONSUMER_KEY, ORGANIZATION)
)ENGINE INNODB;


CREATE TABLE IF NOT EXISTS AM_SUBJECT_ENTITY_REVOKED_EVENT (
    ENTITY_ID       VARCHAR(255)    NOT NULL,
    ENTITY_TYPE     VARCHAR(100)    NOT NULL,
    TIME_REVOKED    TIMESTAMP       NOT NULL,
    ORGANIZATION    VARCHAR(100),
    PRIMARY KEY (ENTITY_ID, ENTITY_TYPE, ORGANIZATION)
)ENGINE INNODB;

