const oracledb = require('oracledb');
const loadEnvFile = require('./utils/envUtil');

const envVariables = loadEnvFile('./.env');

// Database configuration setup. Ensure your .env file has the required database credentials.
const dbConfig = {
    user: envVariables.ORACLE_USER,
    password: envVariables.ORACLE_PASS,
    connectString: `${envVariables.ORACLE_HOST}:${envVariables.ORACLE_PORT}/${envVariables.ORACLE_DBNAME}`,
    poolMin: 1,
    poolMax: 3,
    poolIncrement: 1,
    poolTimeout: 60
};

// initialize connection pool
async function initializeConnectionPool() {
    try {
        await oracledb.createPool(dbConfig);
        console.log('Connection pool started');
    } catch (err) {
        console.error('Initialization error: ' + err.message);
    }
}

async function closePoolAndExit() {
    console.log('\nTerminating');
    try {
        await oracledb.getPool().close(10); // 10 seconds grace period for connections to finish
        console.log('Pool closed');
        process.exit(0);
    } catch (err) {
        console.error(err.message);
        process.exit(1);
    }
}

initializeConnectionPool();

process
    .once('SIGTERM', closePoolAndExit)
    .once('SIGINT', closePoolAndExit);


// ----------------------------------------------------------
// Wrapper to manage OracleDB actions, simplifying connection handling.
async function withOracleDB(action) {
    let connection;
    try {
        connection = await oracledb.getConnection(); // Gets a connection from the default pool 
        await connection.execute("alter session set nls_date_format = 'YYYY-MM-DD'", [], { autoCommit: true });
        return await action(connection);
    } catch (err) {
        console.error(err);
        throw err;
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (err) {
                console.error(err);
            }
        }
    }
}


// ----------------------------------------------------------
// Core functions for database operations
// Modify these functions, especially the SQL queries, based on your project's requirements and design.
async function testOracleConnection() {
    return await withOracleDB(async (connection) => {
        return true;
    }).catch(() => {
        return false;
    });
}

async function fetchDemotableFromDb() {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute('SELECT * FROM DEMOTABLE');
        return result.rows;
    }).catch(() => {
        return [];
    });
}

async function initiateDemotable() {
    return await withOracleDB(async (connection) => {
        try {
            await connection.execute(`DROP TABLE DEMOTABLE`);
        } catch(err) {
            console.log('Table might not exist, proceeding to create...');
        }

        const result = await connection.execute(`
            CREATE TABLE DEMOTABLE (
                id NUMBER PRIMARY KEY,
                name VARCHAR2(20)
            )
        `);
        return true;
    }).catch(() => {
        return false;
    });
}

async function insertDemotable(id, name) {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute(
            `INSERT INTO DEMOTABLE (id, name) VALUES (:id, :name)`,
            [id, name],
            { autoCommit: true }
        );

        return result.rowsAffected && result.rowsAffected > 0;
    }).catch(() => {
        return false;
    });
}

async function updateNameDemotable(oldName, newName) {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute(
            `UPDATE DEMOTABLE SET name=:newName where name=:oldName`,
            [newName, oldName],
            { autoCommit: true }
        );

        return result.rowsAffected && result.rowsAffected > 0;
    }).catch(() => {
        return false;
    });
}

async function countDemotable() {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute('SELECT Count(*) FROM DEMOTABLE');
        return result.rows[0][0];
    }).catch(() => {
        return -1;
    });
}

async function getResults(req) {
    var values=[];
    var query = 'SELECT ' + req.body["proj"] + ' FROM ' + req.body["table"];
    if (Object.keys(req.body["data"]).length > 0) {
        query += " WHERE ";
        for(const c in req.body["data"]){
            if (c == 'Date')
                query += "\"Date\"=:dt AND ";
            else
                query += c + "=:" + c + " AND ";
            values.push(req.body["data"][c]);
        }
        query = query.substring(0, query.length - 5);
    }
    return await withOracleDB(async (connection) => {
        const result = await connection.execute(query, values);
        return result.rows;
    }).catch((e) => {
        return -1;
    });
}

async function getTables() {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute('SELECT table_name FROM user_tables');
        return result.rows;
    }).catch((e) => {
        return -1;
    });
}



async function getColumns(req) {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute("SELECT column_name FROM USER_TAB_COLUMNS WHERE table_name = '" + req.query.table + "' ORDER BY column_id");
        return result.rows;
    }).catch((e) => {
        return -1;
    });
}

async function delRow(req) {
    var query = "DELETE FROM " + req.body["table"] + " WHERE ";
    var values=[];
    for(const c in req.body){
        if(c != "table") {
            if (c == 'Date')
                query += "\"Date\"=:dt AND ";
            else
                query += c + "=:" + c + " AND ";
            values.push(req.body[c]);
        }
    }
    query = query.substring(0, query.length - 5);
    console.log(query);
    return await withOracleDB(async (connection) => {
        const result = await connection.execute(query, values,
            { autoCommit: true }
        );
        return result;
    }).catch((e) => {
        return e;
    });
}

// Class Analytics Page
async function getLevelAvg(req) {
    var query = "SELECT Attendence.classlevel, AVG(Attendence.cnt) FROM (SELECT \"Date\", classlevel, Count(*) as cnt FROM take GROUP BY \"Date\", classlevel) Attendence GROUP BY Attendence.classlevel";
    console.log(query);
    return await withOracleDB(async (connection) => {
        const result = await connection.execute(query, [],
            { autoCommit: true }
        );
        return result.rows;
    }).catch((e) => {
        return e;
    });
}

async function getInstLoad(req) {
    var query = "SELECT InstructorID, Count(*) FROM Class GROUP BY InstructorID";
    console.log(query);
    return await withOracleDB(async (connection) => {
        const result = await connection.execute(query, [],
            { autoCommit: true }
        );
        return result.rows;
    }).catch((e) => {
        return e;
    });
}

async function getLowEnrol(req) {
    var query = "SELECT \"Date\", Count(*) FROM Take WHERE \"Date\">=:dt GROUP BY \"Date\" HAVING Count(*) < 0.5*(SELECT AVG(day.cnt) FROM (SELECT Count(*) cnt FROM Take GROUP BY \"Date\") day)";
    console.log(query);
    console.log(req.query.from);
    return await withOracleDB(async (connection) => {
        const result = await connection.execute(query, [req.query.from],
            { autoCommit: true }
        );
        return result.rows;
    }).catch((e) => {
        return e;
    });
}



//-------------------------------------------------------
// Lift and Run Page functions
async function fetchSkiLiftsFromDb() {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute('SELECT * FROM SkiLift');
        console.log(result.rows); // Check what is being returned
        return result.rows;
    }).catch((e) => {
        return -1;
    });
}

async function fetchSkiRunsFromDb() {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute('SELECT * FROM SkiRun');
        console.log(result.rows); // Check what is being returned
        return result.rows;
    }).catch((e) => {
        console.error('Error fetching ski runs:', e);
        return [];
    });
}


//Join Runs and Lifts
async function findRunsByLift(liftNumber)  {
    return await withOracleDB(async (connection) => {
        const query = `
            SELECT L.liftNumber, L.capacity AS ChairCapacity, L.status AS LiftStatus, R.runNumber, R.difficulty, R.status AS RunStatus
            FROM SkiLift L
            JOIN Accesses A ON L.liftNumber = A.liftNumber
            JOIN SkiRun R ON A.runNumber = R.runNumber
            WHERE L.liftNumber = :liftNumber
        `;
        console.log("Executing query:", query, "with liftNumber:", liftNumber);
        const result = await connection.execute(query, { liftNumber }, { outFormat: oracledb.OUT_FORMAT_OBJECT });
        console.log("Query result:", result.rows);
        return result.rows;
    });
}

//Division for Lifts and Difficulty 
async function findLiftsForDifficulty(difficulty) {
    return await withOracleDB(async (connection) => {
        const query = `
            SELECT DISTINCT L.liftNumber, L.capacity AS ChairCapacity, L.status AS LiftStatus
            FROM SkiLift L
            WHERE NOT EXISTS (
                SELECT 1
                FROM SkiRun R
                WHERE R.difficulty = :difficulty
                AND NOT EXISTS (
                    SELECT 1
                    FROM Accesses A
                    WHERE A.liftNumber = L.liftNumber AND A.runNumber = R.runNumber
                )
            )
            ORDER BY L.liftNumber
        `;
        console.log("Executing query for difficulty:", difficulty);
        const result = await connection.execute(query, { difficulty }, { outFormat: oracledb.OUT_FORMAT_OBJECT });
        console.log("Query result:", result.rows);
        return result.rows;
    });
}

//Selection for run table
async function filterRuns(difficulty, status) {
    return await withOracleDB(async (connection) => {
        let sql = `SELECT * FROM SkiRun`;
        let conditions = [];
        let params = [];

        if (difficulty !== 'All') {
            conditions.push(`difficulty = :difficulty`);
            params.push(difficulty);
        }
        if (status !== 'All') {
            conditions.push(`status = :status`);
            params.push(status);
        }

        if (conditions.length > 0) {
            sql += ` WHERE ${conditions.join(' AND ')}`;
        }

        const result = await connection.execute(sql, params, { outFormat: oracledb.OUT_FORMAT_OBJECT });
        return result.rows;
    });
}


// New Rental
async function newRental(req) {
    var query = "INSERT INTO RENTAL3 VALUES (:dt, :patronid, :equipmentType)";
    var values = [req.body["Date"], req.body["patronID"], req.body["equipmentType"]];
    console.log(query);
    return await withOracleDB(async (connection) => {
        const result = await connection.execute(query, values,
            { autoCommit: true }
        );
        return result;
    }).catch((e) => {
        return e.message;
    });
}

async function patronSearch(req) {
    var query = "SELECT * FROM PATRON";
    var input = inputProccess(req.body["search"]);
    if(input != "") {
        query += " WHERE " + input;
    }
    
    console.log(query);

    return await withOracleDB(async (connection) => {
        const result = await connection.execute(query, [],
            { autoCommit: true }
        );
        return result;
    }).catch((e) => {
        return e.message;
    });
}
function inputProccess(input) {
    let newOut = input.replace(/==/g, '=');
    newOut = newOut.replace(/&&/g, 'AND');
    newOut = newOut.replace(/\|\|/g, 'OR');
    newOut = newOut.replace(/Patron ID/gi, 'patronID');
    newOut = newOut.replace(/"/g, "'");
    // Remove common SQL injection patterns
    return newOut
        .replace(/DROP\s+TABLE/gi, '')
        .replace(/DELETE\s+FROM/gi, '') 
        .replace(/INSERT\s+INTO/gi, '') 
        .replace(/UPDATE/gi, '')
        .replace(/SELECT/gi, '')
        .replace(/CREATE\s+TABLE/gi, '') 
        .replace(/--/g, '')    
        .replace(/;/g, '');  
}

async function updatePatronDetails(patronID, name, email) {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute(
            `UPDATE PATRON SET name = :name, email = :email WHERE patronID = :patronID`,
            { patronID, name, email },
            { autoCommit: true }
        );
        return { success: result.rowsAffected > 0 };
    }).catch((err) => {
        console.error('Failed to update patron details:', err);
        return { success: false };
    });
}

module.exports = {
    testOracleConnection,
    fetchDemotableFromDb,
    initiateDemotable, 
    insertDemotable, 
    updateNameDemotable, 
    countDemotable,
    getResults,
    getTables,
    getColumns,
    delRow,
    getLevelAvg,
    getInstLoad,
    getLowEnrol, 
    fetchSkiLiftsFromDb,
    fetchSkiRunsFromDb,
    findRunsByLift,
    findLiftsForDifficulty,
    filterRuns,
    newRental,
    patronSearch,
    updatePatronDetails
};