-- Setting up a basic table using a SQL script
-- This is the train.csv dataset for the Kaggle Titanic competition
CREATE TABLE train (
    PassengerID VARCHAR,
    Survived VARCHAR,
    Pclass VARCHAR,
    Name VARCHAR,
    Sex VARCHAR,
    Age VARCHAR,
    SibSp VARCHAR,
    Parch VARCHAR,
    Ticket VARCHAR,
    Fare VARCHAR,
    Cabin VARCHAR,
    Embarked VARCHAR
);
COPY train FROM 'data/train.csv'; -- Using a very basic way

-- Creating the test dataset for the Kaggle Titanic competition, using duckdb features
CREATE TABLE test AS
    SELECT * FROM 'data/test.csv';

