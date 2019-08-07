'use strict';

const sql = require('mssql');
const config = require('../config');

const m = module.exports;

const conn = new sql.ConnectionPool({
    user: config.mssql.user,
    password: config.mssql.password,
    server: config.mssql.server,
    database: config.mssql.database
});

// ---------------------------------------------------------------------------------------
const getConn = async () => {
    const pool = new sql.ConnectionPool({
        user: config.mssql.user,
        password: config.mssql.password,
        server: config.mssql.server,
        database: config.mssql.database
    });
    pool.on('error', err => {
        // ... error handler
        throw err;
    });

    return await pool.connect();
};
// ---------------------------------------------------------------------------------------
m.P_Account_Login = async (loginId, nick, loginPlatform, systemLanguage, version) => {
    try {
        const conn = await getConn();
        const result = await conn.request()
                   .input('LoginId', sql.VarChar(50), loginId)
                   .input('Nick', sql.NVarChar(8), nick)
                   .input('LoginPlatform', sql.TinyInt, loginPlatform)
                   .input('SystemLanguage', sql.TinyInt, systemLanguage)
                   .input('Version', sql.Int, version)
                   .output('_AccUid', sql.Int)
                   .output('_Version', sql.Int)
                   .output('_EndTime', sql.SmallDateTime)
                   .output('_BanEndTime', sql.SmallDateTime)
                   .output('_NewCreate', sql.TinyInt)
                   .execute('P_Account_Login');        
        return { success: result };
    } catch (err) {
        console.log(err);
        return { err: err };
    } finally {
        conn.close();
    };
};
// ---------------------------------------------------------------------------------------
m.P_User_Load = async (accUid) => {
    try {
        const conn = await getConn();
        const result = await conn.request()
                    .input('AccUid', sql.Int, accUid)
                    .execute('P_User_Load');
        
        return { success: result };
    } catch (err) {
        console.log(err);
        return { err: err };
    } finally {
        conn.close();
    };
};