'use strict';

const redis = require('ioredis');
const config = require('../config');

const m = module.exports;
m.redis = new redis(config.redis.port, config.redis.host);

const tokenKey = (accUid) => ['t', accUid].join(config.redis.keyDelimiter);

// ---------------------------------------------------------------------------------------
// Login Token
// ---------------------------------------------------------------------------------------
m.setToken = async (accUid, token) => {
    await m.redis.setex(tokenKey(accUid), config.TOKEN_EXPIRE_TIME, token);
};

m.getToken = async (accUid, token) => {
    const myToken = await m.redis.get(tokenKey(accUid));
    if(myToken === token) await m.redis.expire(tokenKey(accUid), config.TOKEN_EXPIRE_TIME);
    return myToken;
};

m.delToken = async (accUid) => {
    await m.redis.del(tokenKey(accUid));
};
// ---------------------------------------------------------------------------------------
