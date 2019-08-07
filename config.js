'use strict';

const config = module.exports;

config.parserLimit = '500kb';
config.serverPort = 7797;

config.redis = {
    host: 'localhost',
    port: 6379,
    keyDelimiter: ':',
    expireTime: 300,
    channel: 'publisherChannel'
};

config.TOKEN_EXPIRE_TIME = 3600;

config.mssql = {
    user: "gmlee",
    password: "dlrhkdals1",
    server: "35.156.134.105",
    database: "GDB",
}