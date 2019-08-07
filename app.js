'use strict';

const express = require('express');
const asyncify = require('express-asyncify');
const session = require('express-session');
const compression = require('compression');
const config = require('./config');
const handles = require('./handles');

(async () => {
    try {
        const server = asyncify(express());
        server.set('view engine', 'ejs');
        server.use(compression());
        server.use(express.json());
        server.use(express.raw({limit: config.parserLimit}));

        // ELB healthCheck
        server.get('/ELB-Health', (req, res) => res.sendStatus(200));
        server.post('/api', handles.handler);
        server.listen(config.serverPort);
        console.log(`[ Game Server On : ${config.serverPort}]`);

    } catch (err) {
        if (typeof err !== 'string') {
            if (err.stack) {
                console.log(err.stack);
                console.log(err.toString());
            } else {
                console.log(err);
            }
        }        
    }
})();