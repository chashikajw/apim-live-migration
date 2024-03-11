-- Alter Tables –

ALTER TABLE AM_API_URL_MAPPING
ADD LOG_LEVEL VARCHAR(255) DEFAULT 'OFF';

ALTER TABLE AM_POLICY_APPLICATION
ADD (RATE_LIMIT_COUNT INTEGER DEFAULT 0,
     RATE_LIMIT_TIME_UNIT VARCHAR(25) DEFAULT NULL);


ALTER TABLE AM_DEPLOYMENT_REVISION_MAPPING 
ADD REVISION_STATUS VARCHAR(255) DEFAULT 'APPROVED' NULL;


ALTER TABLE AM_GATEWAY_ENVIRONMENT
ADD (TYPE VARCHAR(255) DEFAULT 'hybrid' NULL,
     GATEWAY_TYPE VARCHAR(255) DEFAULT 'Regular' NOT NULL);   


-- Add New Tables –

CREATE TABLE AM_KEY_MANAGER_PERMISSIONS (
  KEY_MANAGER_UUID VARCHAR(50) NOT NULL,
  PERMISSIONS_TYPE VARCHAR(50) NOT NULL,
  ROLE VARCHAR(255),
  PRIMARY KEY (KEY_MANAGER_UUID, ROLE),
  FOREIGN KEY (KEY_MANAGER_UUID) REFERENCES AM_KEY_MANAGER(UUID) ON DELETE CASCADE
)
 /


CREATE TABLE AM_GATEWAY_POLICY_METADATA (
    GLOBAL_POLICY_MAPPING_UUID VARCHAR(45)   NOT NULL,
    DISPLAY_NAME               VARCHAR(255)  NULL,
    DESCRIPTION                VARCHAR(1023) NULL,
    ORGANIZATION               VARCHAR(100)  NOT NULL,
    PRIMARY KEY (GLOBAL_POLICY_MAPPING_UUID)
)
/

CREATE TABLE AM_GATEWAY_POLICY_MAPPING (
    POLICY_TO_FLOW_INFO_MAPPING_ID INTEGER,
    GLOBAL_POLICY_MAPPING_UUID     VARCHAR(45)   NOT NULL,
    POLICY_UUID                    VARCHAR(45)   NOT NULL,
    POLICY_ORDER                   INTEGER       NOT NULL,
    DIRECTION                      VARCHAR(10)   NOT NULL,
    PARAMETERS                     VARCHAR(1024) NOT NULL,
    FOREIGN KEY (POLICY_UUID) REFERENCES AM_OPERATION_POLICY (POLICY_UUID) ON DELETE CASCADE,
    FOREIGN KEY (GLOBAL_POLICY_MAPPING_UUID) REFERENCES AM_GATEWAY_POLICY_METADATA (GLOBAL_POLICY_MAPPING_UUID) ON DELETE CASCADE,
    PRIMARY KEY (POLICY_TO_FLOW_INFO_MAPPING_ID)
)
/

CREATE SEQUENCE AM_GATEWAY_POLICY_MAPPING_SEQ START WITH 1 INCREMENT BY 1
/

CREATE OR REPLACE TRIGGER AM_GATEWAY_POLICY_MAPPING_TRIGGER
		            BEFORE INSERT
                    ON AM_GATEWAY_POLICY_MAPPING
                    REFERENCING NEW AS NEW
                    FOR EACH ROW
                    BEGIN
                    SELECT AM_GATEWAY_POLICY_MAPPING_SEQ.nextval INTO :NEW.POLICY_TO_FLOW_INFO_MAPPING_ID FROM dual;
                    END;
/

CREATE TABLE AM_GATEWAY_POLICY_DEPLOYMENT (
    GATEWAY_LABEL              VARCHAR(255) NOT NULL,
    GLOBAL_POLICY_MAPPING_UUID VARCHAR(45)  NOT NULL,
    ORGANIZATION               VARCHAR(100) NOT NULL,
    FOREIGN KEY (GLOBAL_POLICY_MAPPING_UUID) REFERENCES AM_GATEWAY_POLICY_METADATA (GLOBAL_POLICY_MAPPING_UUID) ON DELETE CASCADE,
    PRIMARY KEY (ORGANIZATION,GATEWAY_LABEL)
)
/

CREATE TABLE AM_APP_REVOKED_EVENT
(
    CONSUMER_KEY    VARCHAR(255)    NOT NULL,
    TIME_REVOKED    TIMESTAMP       NOT NULL,
    ORGANIZATION    VARCHAR(100),
    PRIMARY KEY (CONSUMER_KEY, ORGANIZATION)
)
/

CREATE TABLE AM_SUBJECT_ENTITY_REVOKED_EVENT
(
    ENTITY_ID       VARCHAR(255)    NOT NULL,
    ENTITY_TYPE     VARCHAR(100)    NOT NULL,
    TIME_REVOKED    TIMESTAMP       NOT NULL,
    ORGANIZATION    VARCHAR(100),
    PRIMARY KEY (ENTITY_ID, ENTITY_TYPE, ORGANIZATION)
)
/
