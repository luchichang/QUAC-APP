require('dotenv').config();

const {Pool} = require('pg');

const pool = new Pool({
    host: process.env.DB_HOST,
    database: process.env.DATABASE,
    password: process.env.DB_PASSWORD,
    port: process.env.DB_PORT,
    user: process.env.DB_USER,
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 20000
});

// checking the working
pool.connect((err, client, release) => {
    if(err){
        console.error('ERR: Failed connecting to the Postgresql', err.stack);
    }else {
        console.log('INFO: successfully connected to the postgrsql DB on port,',process.env.DB_PORT);
        release();
    }
})

module.exports = {pool};