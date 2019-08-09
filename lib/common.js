'use strict';

const uuidv4 = require('uuid/v4');
const redis = require('./redis');

const m = module.exports;

m.checkParameter = (obj) => {
    return _.isUndefined(obj) || _.isNull(obj) || String(obj) === '';
};

m.randInt = (array) => {
    const min = array[0];
    const max = array[1];
    return Math.floor((max - min + 1) * Math.random()) + min;
};

m.setToken = async (accUid) => {
    const token = uuidv4();
    await redis.setToken(accUid, token);
    return token;
};

m.tableName = (value) => {
    let result = '';
    switch (value) {
        case 0: result = 'user';
            break;
        case 1: result = 'item';
            break;
        case 2: result = 'key';
            break;
        default:
            break;
    }

    return result;
};