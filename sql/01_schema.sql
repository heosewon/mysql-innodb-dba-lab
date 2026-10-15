USE GameOps;

CREATE TABLE GameLog (
    LogID        BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    CreateAt     DATETIME(3) NOT NULL,
    ServerID     INT NOT NULL,
    AccountID    BIGINT UNSIGNED NOT NULL,
    EventType    VARCHAR(30) NOT NULL,
    Amount       INT NOT NULL,
    Detail       VARCHAR(200) NULL,
    PRIMARY KEY (LogID)
) ENGINE=InnoDB;

CREATE TABLE Inventory (
    AccountID BIGINT UNSIGNED NOT NULL,
    ItemID    INT NOT NULL,
    Quantity  INT NOT NULL,
    UpdatedAt DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
        ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (AccountID, ItemID),
    CONSTRAINT CK_Inventory_Quantity CHECK (Quantity >= 0)
) ENGINE=InnoDB;

INSERT INTO Inventory (AccountID, ItemID, Quantity) VALUES
    (1001, 5001, 100),
    (1002, 5001, 100);
