'use strict';

const handles = require('./index');
const config = require('../config');
const mssql = require('../lib/mssql');
const common = require('../lib/common');

handles.user.load = async (data) => {
    const result = await mssql.P_User_Load(data.accUid);
    if (result.err) throw result.err;
    
    let res = [];

    for(const i in result.success.recordsets) {
        const recordSets = result.success.recordsets[i];
        const name = common.tableName(Number(i));

        res.push({table: name, data: recordSets});        
    }
    
    return res;
};