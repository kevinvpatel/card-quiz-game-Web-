const Logger = require('./lib/utils/logger');
const config = require('./config');
const fs = require('fs');
const redis = require('redis');
const {commandOptions} = require('redis');
const {Worker} = require('worker_threads');
const path = require('path');

const logger = new Logger('presAnn Master');
logger.info('Running bbb-export-annotations');

const kickOffCollectorWorker = (jobId) => {
  return new Promise((resolve, reject) => {
    const collectorPath = path.join(__dirname, 'workers', 'collector.js');
    const worker = new Worker(collectorPath, {workerData: jobId});
    worker.on('message', resolve);
    worker.on('error', reject);
    worker.on('exit', (code) => {
      if (code !== 0) {
        reject(new Error(`Collector Worker stopped with exit code ${code}`));
      }
    });
  });
};

(async () => {
  const client = redis.createClient({
    host: config.redis.host,
    port: config.redis.port,
    password: config.redis.password,
  });

  await client.connect();

  client.on('error', (err) => logger.info('Redis Client Error', err));

  /**
   * Pops new export requests from a Redis queue, blocking the
   * connection otherwise.
   */
  async function waitForJobs() {
    const queue = client.blPop(
        commandOptions({isolated: true}),
        config.redis.channels.queue,
        0,
    );

    const job = await queue;

    logger.info('Received job', job.element);
    const exportJob = JSON.parse(job.element);

    // Create folder in dropbox
    const dropbox = path.join(config.shared.presAnnDropboxDir, exportJob.jobId);
    fs.mkdirSync(dropbox, {recursive: true});

    // Drop job into dropbox as JSON
    fs.writeFile(path.join(dropbox, 'job'), job.element, function(err) {
      if (err) {
        return logger.error(err);
      }
    });

    kickOffCollectorWorker(exportJob.jobId);

    waitForJobs();
  }

  waitForJobs();
})();
