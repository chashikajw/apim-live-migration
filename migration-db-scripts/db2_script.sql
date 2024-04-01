-- Alter Tables –

ALTER TABLE AM_API_URL_MAPPING
ADD LOG_LEVEL VARCHAR(255) DEFAULT 'OFF';

ALTER TABLE AM_POLICY_APPLICATION
ADD RATE_LIMIT_COUNT INTEGER NULL DEFAULT 0
ADD RATE_LIMIT_TIME_UNIT VARCHAR(25) NULL DEFAULT NULL;

ALTER TABLE AM_DEPLOYMENT_REVISION_MAPPING
ADD REVISION_STATUS VARCHAR(255) NULL DEFAULT 'APPROVED';


ALTER TABLE AM_GATEWAY_ENVIRONMENT
ADD TYPE VARCHAR(255) NULL DEFAULT 'hybrid'
ADD GATEWAY_TYPE VARCHAR(255) NOT NULL DEFAULT 'Regular';


-- Add New Tables –

CREATE TABLE IDN_INVALID_TOKENS (
 	UUID VARCHAR(255) NOT NULL,
 	TOKEN_IDENTIFIER VARCHAR(2048) NOT NULL,
 	CONSUMER_KEY VARCHAR(255) NOT NULL,
 	TIME_CREATED TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 	EXPIRY_TIMESTAMP TIMESTAMP NOT NULL,
 	PRIMARY KEY (UUID)
);

CREATE TABLE IDN_APP_REVOKED_EVENT (
	EVENT_ID VARCHAR(255) NOT NULL,
	CONSUMER_KEY VARCHAR(255) NOT NULL,
	TIME_REVOKED TIMESTAMP NOT NULL,
	ORGANIZATION VARCHAR(100),
	PRIMARY KEY (EVENT_ID),
	CONSTRAINT CON_APP_EVT_KEY UNIQUE (CONSUMER_KEY, ORGANIZATION)
);

CREATE TABLE IDN_SUBJECT_ENTITY_REVOKED_EVENT (
	EVENT_ID VARCHAR(255) NOT NULL,
    ENTITY_ID VARCHAR(255) NOT NULL,
    ENTITY_TYPE VARCHAR(100) NOT NULL,
    TIME_REVOKED TIMESTAMP NOT NULL,
    ORGANIZATION VARCHAR(100),
    PRIMARY KEY (EVENT_ID),
    CONSTRAINT CON_SUB_EVT_KEY UNIQUE (ENTITY_ID, ENTITY_TYPE, ORGANIZATION)
);


CREATE TABLE AM_KEY_MANAGER_PERMISSIONS (
  KEY_MANAGER_UUID VARCHAR(50) NOT NULL,
  PERMISSIONS_TYPE VARCHAR(50) NOT NULL,
  ROLE VARCHAR(255) NOT NULL,
  PRIMARY KEY (KEY_MANAGER_UUID, ROLE),
  FOREIGN KEY (KEY_MANAGER_UUID) REFERENCES AM_KEY_MANAGER(UUID) ON DELETE CASCADE
);

CREATE TABLE AM_GATEWAY_POLICY_METADATA (
    GLOBAL_POLICY_MAPPING_UUID VARCHAR(45) NOT NULL,
    DISPLAY_NAME               VARCHAR(255) NULL,
    DESCRIPTION                VARCHAR(1023) NULL,
    ORGANIZATION               VARCHAR(100) NOT NULL,
    PRIMARY KEY (GLOBAL_POLICY_MAPPING_UUID)
);

CREATE TABLE AM_GATEWAY_POLICY_MAPPING (
    POLICY_TO_FLOW_INFO_MAPPING_ID INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
    GLOBAL_POLICY_MAPPING_UUID     VARCHAR(45)   NOT NULL,
    POLICY_UUID                    VARCHAR(45)   NOT NULL,
    POLICY_ORDER                   INTEGER       NOT NULL,
    DIRECTION                      VARCHAR(10)   NOT NULL,
    PARAMETERS                     VARCHAR(1024) NOT NULL,
    FOREIGN KEY (POLICY_UUID) REFERENCES AM_OPERATION_POLICY (POLICY_UUID) ON UPDATE RESTRICT ON DELETE RESTRICT,
    FOREIGN KEY (GLOBAL_POLICY_MAPPING_UUID) REFERENCES AM_GATEWAY_POLICY_METADATA (GLOBAL_POLICY_MAPPING_UUID) ON UPDATE RESTRICT ON DELETE CASCADE,
    PRIMARY KEY (POLICY_TO_FLOW_INFO_MAPPING_ID)
);


CREATE TABLE AM_GATEWAY_POLICY_DEPLOYMENT (
    GATEWAY_LABEL              VARCHAR(255) NOT NULL,
    GLOBAL_POLICY_MAPPING_UUID VARCHAR(45)  NOT NULL,
    ORGANIZATION               VARCHAR(100) NOT NULL,
    FOREIGN KEY (GLOBAL_POLICY_MAPPING_UUID) REFERENCES AM_GATEWAY_POLICY_METADATA (GLOBAL_POLICY_MAPPING_UUID) ON UPDATE RESTRICT ON DELETE RESTRICT,
    PRIMARY KEY (ORGANIZATION,GATEWAY_LABEL)
);

CREATE TABLE AM_APP_REVOKED_EVENT
(
    CONSUMER_KEY    VARCHAR(255)    NOT NULL,
    TIME_REVOKED    TIMESTAMP       NOT NULL,
    ORGANIZATION    VARCHAR(100)    NOT NULL,
    PRIMARY KEY (CONSUMER_KEY, ORGANIZATION)
);

CREATE TABLE AM_SUBJECT_ENTITY_REVOKED_EVENT
(
    ENTITY_ID      VARCHAR(255)    NOT NULL,
    ENTITY_TYPE    VARCHAR(100)    NOT NULL,
    TIME_REVOKED   TIMESTAMP       NOT NULL,
    ORGANIZATION   VARCHAR(100)    NOT NULL,
    PRIMARY KEY (ENTITY_ID, ENTITY_TYPE, ORGANIZATION)
)


