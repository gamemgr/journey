'use strict';

const handles = require('./index');
const config = require('../config');
const mssql = require('../lib/mssql');
const common = require('../lib/common');

handles.user.load = async (data) => {
    const result = await mssql.P_User_Load(data.accUid);
    let res = [];

    for(const o in result.success.recordsets) {
        const recordSets = result.success.recordsets[o];
        const name = common.tableName(Number(o));

        res.push({table: name, data: recordSets});        
    }
    
    return res;
};