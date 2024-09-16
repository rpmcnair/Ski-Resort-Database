const express = require('express');
const appService = require('./appService');

const router = express.Router();


// ----------------------------------------------------------
// API endpoints
// Modify or extend these routes based on your project's needs.
router.get('/check-db-connection', async (req, res) => {
    const isConnect = await appService.testOracleConnection();
    if (isConnect) {
        res.send('connected');
    } else {
        res.send('unable to connect');
    }
});

router.get('/demotable', async (req, res) => {
    const tableContent = await appService.fetchDemotableFromDb();
    res.json({data: tableContent});
});

router.post("/initiate-demotable", async (req, res) => {
    const initiateResult = await appService.initiateDemotable();
    if (initiateResult) {
        res.json({ success: true });
    } else {
        res.status(500).json({ success: false });
    }
});

router.post("/insert-demotable", async (req, res) => {
    const { id, name } = req.body;
    const insertResult = await appService.insertDemotable(id, name);
    if (insertResult) {
        res.json({ success: true });
    } else {
        res.status(500).json({ success: false });
    }
});

router.post("/update-name-demotable", async (req, res) => {
    const { oldName, newName } = req.body;
    const updateResult = await appService.updateNameDemotable(oldName, newName);
    if (updateResult) {
        res.json({ success: true });
    } else {
        res.status(500).json({ success: false });
    }
});

router.get('/count-demotable', async (req, res) => {
    const tableCount = await appService.countDemotable();
    if (tableCount >= 0) {
        res.json({ 
            success: true,  
            count: tableCount
        });
    } else {
        res.status(500).json({ 
            success: false, 
            count: tableCount
        });
    }
});

// Projection Page (classes.html)
router.post('/getresults', async (req, res) => { 
    var tableContent = await appService.getResults(req);
    res.json({data: tableContent});
});

router.get('/get-tables', async (req, res) => { 
    var tables = await appService.getTables();
    res.json({data: tables});
});

router.get('/get-columns', async (req, res) => { 
    var columns = await appService.getColumns(req);
    res.json({data: columns});
});

router.post('/del-row', async (req, res) => { 
    var status = await appService.delRow(req);
    res.send(status);
});

// Class Analytics Page
router.get('/getlevelavg', async (req, res) => { 
    var result = await appService.getLevelAvg(req);
    res.json({data: result});
});

router.get('/getinstload', async (req, res) => { 
    var result = await appService.getInstLoad(req);
    res.json({data: result});
});

router.get('/getlowenrol', async (req, res) => { 
    var result = await appService.getLowEnrol(req);
    res.json({data: result});
});


// Class Analytics Page
router.get('/getlevelavg', async (req, res) => { 
    var result = await appService.getLevelAvg(req);
    res.json({data: result});
});

router.get('/getinstload', async (req, res) => { 
    var result = await appService.getInstLoad(req);
    res.json({data: result});
});

router.get('/getlowenrol', async (req, res) => { 
    var result = await appService.getLowEnrol(req);
    res.json({data: result});
});


//-------------------------------------------------------
//Ski run and lift page
router.get('/get-ski-lifts', async (req, res) => {
    var tables = await appService.fetchSkiLiftsFromDb();
    res.json({data: tables});
});

router.get('/get-ski-runs', async (req, res) => {
    const runs = await appService.fetchSkiRunsFromDb();
    res.json({data: runs});
});


// Join runs and lifts
router.get('/runs-for-lift', async (req, res) => {
    const { liftNumber } = req.query;
    console.log("Received request for liftNumber:", liftNumber); 
    try {
        const runs = await appService.findRunsByLift(liftNumber);
        console.log("Runs found:", runs); 
        res.json(runs);
    } catch (error) {
        console.error("Error finding runs for lift:", error); 
        res.status(500).json({ error: error.message || "Internal server error" });
    }
});

//Division Run Difficulty and Lifts
router.get('/find-lifts-for-difficulty', async (req, res) => {
    const { difficulty } = req.query;
    console.log("Received request for difficulty:", difficulty);
    try {
        const lifts = await appService.findLiftsForDifficulty(difficulty);
        console.log("Lifts found:", lifts);
        res.json(lifts);
    } catch (error) {
        console.error("Error finding lifts for difficulty:", error);
        res.status(500).json({ error: error.message || "Internal server error" });
    }
});

//Selection 
router.get('/api/filter-runs', async (req, res) => {
    const { difficulty, status } = req.query;

    try {
        const results = await appService.filterRuns(difficulty, status);
        res.json(results);
    } catch (error) {
        console.error('Error in query:', error);
        res.status(500).send('Error fetching runs');
    }
});

// new rental page
router.post('/new-rental', async (req, res) => { 
    var status = await appService.newRental(req);
    res.send(status);
});

// Patron search page
router.post('/patron-search.html',  async (req, res) => { 
    var status = await appService.patronSearch(req);
    res.json(status);
});

router.post("/update-patron", async (req, res) => {
    const { id, name, email } = req.body;
    try {
        const updateResult = await appService.updatePatronDetails(id, name, email);
        if (updateResult.success) {
            res.json({ success: true });
        } else {
            throw new Error('Update failed');
        }
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

module.exports = router;