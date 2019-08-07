'use strict';

const handles = require('./index');
const mssql = require('../lib/mssql');
const common = require('../lib/common');

handles.process.login = async (data) => {
    const result = await mssql.P_Account_Login(data.loginId, data.nick, data.loginPlatform, data.systemLanguage, data.version);
    if (result.err) throw result.err;
    
    let res = [];

    const errCode = result.success.returnValue;
    const output = result.success.output;

    let token = null;
    if (errCode === 0) token = await common.setToken(output._AccUid);    

    const param = { 
        accUid: output._AccUid,
        version: output._Version,
        endTime: output._EndTime,
        banEndTime: output._BanEndTime,
        newCreate: output._NewCreate,
        token: token
    };
    
    res.push({cmd: 'login', errCode: errCode, param: param});
    return res;
};