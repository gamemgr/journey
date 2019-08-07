const _ = require('lodash');
const fs = require('fs');
const redis = require('../lib/redis');
const common = require('../lib/common');

const m = module.exports;

m.handles = {};
m.process = {};
m.user = {};
m.cmds = {};

fs.readdirSync('handles').forEach(v => {
    if (v === 'index.js') return;
    if (!fs.statSync(['.', 'handles', v].join('/')).isFile()) return;
    require(['.', v.split('.')[0]].join('/'));
});

_.forEach(m.process, (fn, key) => m.cmds[key] = {fn: fn, type: 'process'});
_.forEach(m.user, (fn, key) => m.cmds[key] = {fn: fn, type: 'user'});

const getUser = async (data) => {
    // svr <-> redis user get

};

const userHandler = async (handle, data) => {
    if (common.checkParameter(data.accUid)) throw 1000;     // CONST.ERROR_MSG.MISSING_PARAMETER;
    if (common.checkParameter(data.token)) throw 2000;      // CONST.ERROR_MSG.MISSING_PARAMETER;
    if (data.accUid === null)

    var check = await redis.getToken(data.accUid, data.token);
    if (check === null) throw 3000; // CONST.ERROR_MSG.LOGIN_ERROR;
    if (check !== data.token) throw 4000; // CONST.ERROR_MSG.OVERLAP_LOGIN;

    return await handle.fn(data);
};

m.handler = async (req, res) => {
    try {
        let body = req.body;
        if (Array.isArray(body)) body = body[0];
    
        //console.log("handler req : " + JSON.stringify(data));
        //console.log("handler res : " + res);
    
        const handle = m.cmds[body.cmd];
        if (!handle) throw 9999;

        let resData;
        if (handle.type === 'process') {
            resData = await handle.fn(body);
        } else {
            resData = await userHandler(handle, body);
        }

        let resData = await handle.fn(body);
        resData = JSON.stringify(resData);
        // ans = Buffer.from(ans, 'utf-8');     // 필요없는듯? 체크 필요.
        
        res.set('content-length', resData.length);
        res.write(resData);
        res.end();

        console.log(resData);
    } catch (err) {
        console.log(err);
    }    
};