var config = {};

config.serverUrl= "10.50.0.112"

config.mosiPin = 5;
config.sclkPin = 6;
config.powerOnPin = 21;
config.powerOkPin = 20;

//[Name, Datasheet Voltage, GPIO PIN Number, Serial No.?]
//config for hvpia
// config.positionList = [
//   ["FV1",53.57,22],
//   ["FV2",53.57,23],
//   ["FV3",53.57,24],
//   ["FV4",53.57,10],
//   ["FH1",53.57,09],
//   ["FH2",53.57,25],
//   ["FH3",53.57,11],
//   ["FH4",53.57,08]
// ];
//config for hvPib
// config.positionList = [
//   ["FV1",53.57,02],
//   ["FV2",53.57,03],
//   ["FV3",53.57,04],
//   ["FV4",53.57,14],
//   ["FH1",53.57,15],
//   ["FH2",53.57,17],
//   ["FH3",53.57,18],
//   ["FH4",53.57,27]
// ];
//config for sawaizTestPi
config.positionList = [
  ["FV1",53.57,07],
  ["FV2",53.57,12],
  ["FV3",53.57,13],
  ["FV4",53.57,19],
  ["FH1",53.57,16],
  ["FH2",53.57,26],
  ["FH3",53.57,00],
  ["FH4",53.57,00]
];

config.twitter = {};
config.redis = {};
config.web = {};

config.default_stuff =  ['red','green','blue','apple','yellow','orange','politics'];
config.twitter.user_name = process.env.TWITTER_USER || 'username';
config.twitter.password=  process.env.TWITTER_PASSWORD || 'password';
config.redis.uri = process.env.DUOSTACK_DB_REDIS;
config.redis.host = 'hostname';
config.redis.port = 6379;
config.web.port = process.env.WEB_PORT || 9980;

module.exports = config;
